import SwiftUI
import Observation

@MainActor
@Observable
final class CalendarViewModel {
    
    // MARK: - Init
    
    init(router: CalendarRouter) {
        self.router = router
    }
    
    // MARK: - Internal Methods
    
    func openProfile() {
        router.routeTo(destination: .profile)
    }
    
    // MARK: - Private Properties
    
    private let router: CalendarRouter
}
