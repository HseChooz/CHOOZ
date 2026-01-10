import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let appRouter = AppRouter(window: window)
        let appContainer = AppContainer(appRouter: appRouter)
        appBootstraper = AppBootstraper(appContainer: appContainer)
        appBootstraper?.start()
        
        return true
    }
    
    private var appBootstraper: AppBootstraper?
}

