import Foundation

final class NotesTabAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.notesTab)
    }
    
    func trackProfileOpened() {
        analyticsService.track(.profileOpened(source: Screen.notesTab.rawValue))
    }
    
    func trackNoteCreated(title: String) {
        analyticsService.track(.noteCreated(title: title))
    }
    
    func trackNoteEdited(noteId: String) {
        analyticsService.track(.noteEdited(noteId: noteId))
    }
    
    func trackNoteDeleted(noteId: String) {
        analyticsService.track(.noteDeleted(noteId: noteId))
    }
    
    func trackNoteFavoriteToggled(noteId: String, enabled: Bool) {
        analyticsService.track(.noteFavoriteToggled(noteId: noteId, enabled: enabled))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
