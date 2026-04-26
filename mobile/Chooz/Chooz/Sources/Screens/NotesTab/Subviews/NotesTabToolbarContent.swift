import SwiftUI

@MainActor
protocol NotesTabToolbarContentEventsHandler {
    func openProfile()
}

struct NotesTabToolbarContent: ToolbarContent {
    
    // MARK: - Init
    
    init(
        selectedSegment: Binding<NotesTabSegment>,
        eventsHandler: NotesTabToolbarContentEventsHandler
    ) {
        self._selectedSegment = selectedSegment
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NotesTabSegmentPickerView(
                segments: NotesTabSegment.allCases,
                selectedSegment: $selectedSegment
            )
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButtonView(action: eventsHandler.openProfile)
        }
    }
    
    // MARK: - Private Properties
    
    @Binding private var selectedSegment: NotesTabSegment
    
    private let eventsHandler: NotesTabToolbarContentEventsHandler
    
}
