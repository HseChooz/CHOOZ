import UIKit
import AppMetricaCore
import GoogleSignIn
import YandexLoginSDK

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Internal Properties
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let openingURL = incomingURL(from: connectionOptions)
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        self.window = window
        
        if let openingURL {
            AppMetrica.trackOpeningURL(openingURL)
        }
        
        let appRouter = AppRouter(window: window)
        let appContainer = AppContainer(appRouter: appRouter)
        self.appContainer = appContainer
        if let openingURL {
            _ = appContainer.deepLinkService.queue(url: openingURL)
        }
        appBootstraper = AppBootstraper(appContainer: appContainer)
        appBootstraper?.start()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        AppMetrica.trackOpeningURL(url)
        
        if appContainer?.deepLinkService.handle(url: url) == true {
            return
        }
        
        GIDSignIn.sharedInstance.handle(url)
        try? YandexLoginSDK.shared.handleOpenURL(url)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL
        else {
            return
        }

        AppMetrica.trackOpeningURL(url)
        _ = appContainer?.deepLinkService.handle(url: url)
    }
    
    // MARK: - Private Properties
    
    private var appContainer: AppContainer?
    private var appBootstraper: AppBootstraper?

    // MARK: - Private Methods

    private func incomingURL(from connectionOptions: UIScene.ConnectionOptions) -> URL? {
        if let url = connectionOptions.urlContexts.first?.url {
            return url
        }

        return connectionOptions.userActivities.first(where: {
            $0.activityType == NSUserActivityTypeBrowsingWeb
        })?.webpageURL
    }
}
