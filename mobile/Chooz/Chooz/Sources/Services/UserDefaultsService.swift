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
    
    // MARK: - Private Types
    
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
}
