import Foundation

enum DeepLink {
    case profile(userId: String)
}

@MainActor
final class DeepLinkService {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, socialProfileFactory: SocialProfileFactory) {
        self.appRouter = appRouter
        self.socialProfileFactory = socialProfileFactory
    }
    
    // MARK: - Internal Methods
    
    func handle(url: URL) -> Bool {
        guard let deepLink = parse(url: url) else { return false }
        
        switch deepLink {
        case .profile(let userId):
            let vc = socialProfileFactory.makeScreen(userId: userId)
            appRouter.present(vc)
        }
        
        return true
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let socialProfileFactory: SocialProfileFactory
    
    // MARK: - Private Methods
    
    private func parse(url: URL) -> DeepLink? {
        guard url.scheme == "chooz", url.host == "profile" else { return nil }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let userId = pathComponents.first else { return nil }
        
        return .profile(userId: userId)
    }
}
