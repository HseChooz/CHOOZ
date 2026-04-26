import Foundation

@MainActor
protocol FavoriteNotesFactoryDeps:
    FavoriteNotesRouterDeps,
    NotesInteractorDeps
{
    var noteActionPerformerProducer: NoteActionPerformerProducer { get }
}

@MainActor
struct FavoriteNotesFactoryDepsImpl: FavoriteNotesFactoryDeps {
    let appRouter: AppRouter
    let noteFormFactory: NoteFormFactory
    let noteDetailsFactory: NoteDetailsFactory
    let notesService: NotesService
    let noteActionPerformerProducer: NoteActionPerformerProducer
}
