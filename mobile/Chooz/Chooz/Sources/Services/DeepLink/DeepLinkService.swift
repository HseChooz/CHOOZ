import Foundation

enum DeepLink {
    case profile(userId: String)
}

@MainActor
final class DeepLinkService {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        socialProfileFactory: SocialProfileFactory,
        tokenStorage: TokenStorage
    ) {
        self.appRouter = appRouter
        self.socialProfileFactory = socialProfileFactory
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Internal Properties
    
    private(set) var pendingDeepLink: DeepLink?
    
    // MARK: - Internal Methods
    
    @discardableResult
    func handle(url: URL) -> Bool {
        guard let deepLink = parse(url: url) else { return false }
        
        guard tokenStorage.isLoggedIn else {
            pendingDeepLink = deepLink
            return true
        }
        
        navigate(to: deepLink)
        return true
    }
    
    func consumePendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        navigate(to: deepLink)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let socialProfileFactory: SocialProfileFactory
    private let tokenStorage: TokenStorage
    
    // MARK: - Private Methods
    
    private func navigate(to deepLink: DeepLink) {
        switch deepLink {
        case .profile(let userId):
            let vc = socialProfileFactory.makeScreen(userId: userId)
            appRouter.push(vc)
        }
    }
    
    private func parse(url: URL) -> DeepLink? {
        guard url.scheme == "chooz", url.host == "profile" else { return nil }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let userId = pathComponents.first else { return nil }
        
        return .profile(userId: userId)
    }
    
}
