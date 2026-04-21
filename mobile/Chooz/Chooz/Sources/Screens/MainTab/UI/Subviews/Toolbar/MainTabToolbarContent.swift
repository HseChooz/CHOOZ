import SwiftUI

@MainActor
protocol MainTabToolbarContentEventsHandler {
    func openProfile()
}

struct MainTabToolbarContent: ToolbarContent {
    
    // MARK: - Init
    
    init(eventsHandler: MainTabToolbarContentEventsHandler) {
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButtonView(action: eventsHandler.openProfile)
        }
    }
    
    // MARK: - Private Properties
    
    private let eventsHandler: MainTabToolbarContentEventsHandler
    
}
