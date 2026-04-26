import Foundation

final class NoteDetailsAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.noteDetails)
    }
    
    func trackNoteLinkOpened(noteId: String) {
        analyticsService.track(.noteLinkOpened(noteId: noteId))
    }
    
    func trackNoteFormOpened(mode: String) {
        analyticsService.track(.noteFormOpened(mode: mode, source: Screen.noteDetails.rawValue))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
