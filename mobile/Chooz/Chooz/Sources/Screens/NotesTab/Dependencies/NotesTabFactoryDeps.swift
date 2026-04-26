import Foundation

@MainActor
protocol NotesTabFactoryDeps:
    NotesTabRouterDeps
{
    var notesFactory: NotesFactory { get }
    var favoriteNotesFactory: FavoriteNotesFactory { get }
    var noteActionPerformerProducer: NoteActionPerformerProducer { get }
    var toastManager: ToastManager { get }
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct NotesTabFactoryDepsImpl: NotesTabFactoryDeps {
    let appRouter: AppRouter
    let profileFactory: ProfileFactory
    let notesFactory: NotesFactory
    let favoriteNotesFactory: FavoriteNotesFactory
    let noteActionPerformerProducer: NoteActionPerformerProducer
    let toastManager: ToastManager
    let analyticsService: AnalyticsService
}
