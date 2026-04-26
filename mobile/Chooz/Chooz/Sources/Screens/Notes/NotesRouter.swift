import Foundation
import UIKit

@MainActor
protocol NotesRouterDeps {
    var appRouter: AppRouter { get }
    var noteFormFactory: NoteFormFactory { get }
    var noteDetailsFactory: NoteDetailsFactory { get }
}

enum NotesDestination {
    case noteForm(
        formType: NoteFormType,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter
    )
    case noteDetails(noteModel: NoteModel)
}

@MainActor
final class NotesRouter {

    // MARK: - Init

    init(deps: NotesRouterDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func routeTo(destination: NotesDestination) {
        switch destination {
        case .noteForm(let formType, let notePerformer, let noteReporter):
            let vc = deps.noteFormFactory.makeScreen(
                with: formType,
                notePerformer: notePerformer,
                noteReporter: noteReporter
            )
            deps.appRouter.presentAdaptivePopup(vc)
        case .noteDetails(let model):
            let vc = deps.noteDetailsFactory.makeScreen(with: model)
            deps.appRouter.presentAdaptivePopup(vc)
        }
    }

    // MARK: - Private Methods

    private let deps: NotesRouterDeps

}
