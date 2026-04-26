import Foundation

final class FavoriteNotesAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.favoriteNotes)
    }
    
    func trackNoteFormOpened(mode: String) {
        analyticsService.track(.noteFormOpened(mode: mode, source: Screen.favoriteNotes.rawValue))
    }
    
    func trackNoteDetailsOpened(noteId: String) {
        analyticsService.track(.noteDetailsOpened(noteId: noteId, source: Screen.favoriteNotes.rawValue))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
