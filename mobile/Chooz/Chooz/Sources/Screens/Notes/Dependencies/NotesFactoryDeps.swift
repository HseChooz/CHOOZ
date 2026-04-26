import Foundation

@MainActor
protocol NotesFactoryDeps:
    NotesRouterDeps,
    NotesInteractorDeps
{
    var noteActionPerformerProducer: NoteActionPerformerProducer { get }
}

@MainActor
struct NotesFactoryDepsImpl: NotesFactoryDeps {
    let appRouter: AppRouter
    let noteFormFactory: NoteFormFactory
    let notesService: NotesService
    let noteActionPerformerProducer: NoteActionPerformerProducer
    let noteDetailsFactory: NoteDetailsFactory
}
