import UIKit
import AppMetricaCore
import AppMetricaCrashes

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UserDefaults.standard.register(defaults: ["UseFloatingTabBar": false])
        
        if let configuration = AppMetricaConfiguration(apiKey: AppConfig.appMetricaAPIKey) {
            #if DEBUG
            configuration.areLogsEnabled = true
            #endif
            let isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            configuration.handleFirstActivationAsUpdate = !isFirstLaunch
            AppMetrica.activate(with: configuration)
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

