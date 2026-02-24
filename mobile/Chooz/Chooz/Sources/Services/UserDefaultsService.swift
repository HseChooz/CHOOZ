import Foundation

@MainActor
final class UserDefaultsService {
    
    // MARK: - Internal Properties
    
    var hasSeenOnboarding: Bool {
        get {
            userDefaults.bool(forKey: Keys.hasSeenOnboarding)
        } set {
            userDefaults.set(newValue, forKey: Keys.hasSeenOnboarding)
        }
    }
    
    var notificationsEnabled: Bool {
        get {
            userDefaults.bool(forKey: Keys.notificationsEnabled)
        } set {
            userDefaults.set(newValue, forKey: Keys.notificationsEnabled)
        }
    }
    
    var isFirstLaunchAfterInstall: Bool {
        !userDefaults.bool(forKey: Keys.hasLaunchedBefore)
    }
    
    // MARK: - Internal Methods
    
    func markAsLaunched() {
        userDefaults.set(true, forKey: Keys.hasLaunchedBefore)
    }
    
    // MARK: - Private Types
    
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
}
