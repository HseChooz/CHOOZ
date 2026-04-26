import Foundation

@MainActor
protocol NoteDetailsFactoryDeps:
    NoteDetailsRouterDeps
{
    var noteActionPerformerProducer: NoteActionPerformerProducer { get }
    var toastManager: ToastManager { get }
}

@MainActor
struct NoteDetailsFactoryDepsImpl: NoteDetailsFactoryDeps {
    let appRouter: AppRouter
    let noteFormFactory: NoteFormFactory
    let noteActionPerformerProducer: NoteActionPerformerProducer
    let toastManager: ToastManager
}
