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
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
}
