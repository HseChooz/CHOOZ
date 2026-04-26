import Foundation
import UIKit

@MainActor
protocol NoteDetailsRouterDeps {
    var appRouter: AppRouter { get }
    var noteFormFactory: NoteFormFactory { get }
}

enum NoteDetailsDestination {
    case noteForm(
        formType: NoteFormType,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter
    )
}

@MainActor
final class NoteDetailsRouter {

    // MARK: - Init

    init(deps: NoteDetailsRouterDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func routeTo(destination: NoteDetailsDestination) {
        switch destination {
        case .noteForm(let formType, let notePerformer, let noteReporter):
            let vc = deps.noteFormFactory.makeScreen(
                with: formType,
                notePerformer: notePerformer,
                noteReporter: noteReporter
            )
            deps.appRouter.replacePresentedAdaptivePopup(with: vc)
        }
    }

    // MARK: - Private Methods

    private let deps: NoteDetailsRouterDeps

}
