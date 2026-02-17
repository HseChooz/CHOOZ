import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Init
    
    init(
        router: SettingsRouter,
        sessionService: SessionService
    ) {
        self.router = router
        self.sessionService = sessionService
    }
    
    // MARK: - Internal Methods
    
    func logout() {
        sessionService.handleSessionExpired()
    }
    
    // MARK: - Private Properties
    
    private let router: SettingsRouter
    private let sessionService: SessionService
}
