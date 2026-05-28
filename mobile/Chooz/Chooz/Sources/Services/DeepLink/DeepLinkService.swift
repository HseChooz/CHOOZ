import Foundation

extension AppConfig {
    static let defaultUniversalLinkHost = apiBaseURL.host ?? "chooz-hse.ru"
}

enum DeepLink: Equatable {
    case profile(userId: String)
    case wishlistShare(token: String)
}

@MainActor
final class DeepLinkService {
    
    // MARK: - Init
    
    init(
        appRouter: any AppRouting,
        socialProfileFactory: any SocialProfileScreenBuilding,
        tokenStorage: any AuthStateProviding,
        wishlistShareRouteResolver: any WishlistShareRouteResolving,
        toastManager: any ToastPresenting,
        universalLinkHost: String = AppConfig.defaultUniversalLinkHost,
        appScheme: String = "chooz"
    ) {
        self.appRouter = appRouter
        self.socialProfileFactory = socialProfileFactory
        self.tokenStorage = tokenStorage
        self.wishlistShareRouteResolver = wishlistShareRouteResolver
        self.toastManager = toastManager
        self.universalLinkHost = universalLinkHost
        self.appScheme = appScheme
    }
    
    // MARK: - Internal Properties
    
    private(set) var pendingDeepLink: DeepLink?
    
    // MARK: - Internal Methods
    
    @discardableResult
    func handle(url: URL) -> Bool {
        guard let deepLink = parse(url: url) else { return false }

        route(to: deepLink)
        return true
    }

    @discardableResult
    func queue(url: URL) -> Bool {
        guard let deepLink = parse(url: url) else { return false }

        pendingDeepLink = deepLink
        return true
    }
    
    func consumePendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        route(to: deepLink)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: any AppRouting
    private let socialProfileFactory: any SocialProfileScreenBuilding
    private let tokenStorage: any AuthStateProviding
    private let wishlistShareRouteResolver: any WishlistShareRouteResolving
    private let toastManager: any ToastPresenting
    private let universalLinkHost: String
    private let appScheme: String
    
    // MARK: - Private Methods
    
    private func route(to deepLink: DeepLink) {
        guard tokenStorage.isLoggedIn else {
            pendingDeepLink = deepLink
            return
        }

        Task { @MainActor in
            await navigate(to: deepLink)
        }
    }

    private func navigate(to deepLink: DeepLink) async {
        switch deepLink {
        case .profile(let userId):
            openSocialProfile(userId: userId)
        case .wishlistShare(let token):
            do {
                let userId = try await wishlistShareRouteResolver.resolveUserId(token: token)
                openSocialProfile(userId: userId)
            } catch let error as WishlistShareRouteResolverError {
                switch error {
                case .unavailable:
                    toastManager.showError("Ссылка недоступна", subtitle: nil)
                case .unauthorized:
                    pendingDeepLink = deepLink
                case .failed(let message):
                    toastManager.showError("Не удалось открыть вишлист", subtitle: message)
                }
            } catch {
                toastManager.showError("Не удалось открыть вишлист", subtitle: nil)
            }
        }
    }
    
    private func parse(url: URL) -> DeepLink? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        if url.scheme?.lowercased() == appScheme {
            switch url.host?.lowercased() {
            case "profile":
                guard let userId = pathComponents.first else { return nil }
                return .profile(userId: userId)
            case "wishlist":
                guard let token = pathComponents.first else { return nil }
                return .wishlistShare(token: token)
            default:
                return nil
            }
        }

        guard
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            url.host?.lowercased() == universalLinkHost.lowercased(),
            pathComponents.count >= 2,
            pathComponents[0].lowercased() == "wishlist"
        else {
            return nil
        }

        return .wishlistShare(token: pathComponents[1])
    }

    private func openSocialProfile(userId: String) {
        let vc = socialProfileFactory.makeScreen(userId: userId)
        appRouter.push(vc, animated: true, hideBackButton: false)
    }
    
}
