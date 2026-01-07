import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let appContainer = AppContainer()
        appCoordinator = AppCoordinator(window: window, appContainer: appContainer)
        appCoordinator?.start()
        
        return true
    }
    
    private var appCoordinator: AppCoordinator?
}

