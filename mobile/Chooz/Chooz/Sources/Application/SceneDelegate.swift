import UIKit
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
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let appRouter = AppRouter(window: window)
        let appContainer = AppContainer(appRouter: appRouter)
        self.appContainer = appContainer
        appBootstraper = AppBootstraper(appContainer: appContainer)
        appBootstraper?.start()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        if appContainer?.deepLinkService.handle(url: url) == true {
            return
        }
        
        GIDSignIn.sharedInstance.handle(url)
        try? YandexLoginSDK.shared.handleOpenURL(url)
    }
    
    // MARK: - Private Properties
    
    private var appContainer: AppContainer?
    private var appBootstraper: AppBootstraper?
}
