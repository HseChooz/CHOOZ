import Foundation

final class NotesAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.notes)
    }
    
    func trackNoteFormOpened(mode: String) {
        analyticsService.track(.noteFormOpened(mode: mode, source: Screen.notes.rawValue))
    }
    
    func trackNoteDetailsOpened(noteId: String) {
        analyticsService.track(.noteDetailsOpened(noteId: noteId, source: Screen.notes.rawValue))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
