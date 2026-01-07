import Foundation

@MainActor
final class AppContainer {
    
    // MARK: - Factories
    
    lazy var authScreenFactory: AuthScreenFactory = AuthScreenFactory()
    
}
