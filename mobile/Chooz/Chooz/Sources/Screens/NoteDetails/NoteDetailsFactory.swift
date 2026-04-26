import Foundation
import SwiftUI
import UIKit

@MainActor
struct NoteDetailsFactory {

    // MARK: - Init

    init(deps: NoteDetailsFactoryDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makeScreen(
        with noteModel: NoteModel
    ) -> UIViewController {
        let router = NoteDetailsRouter(deps: deps)
        let notePerformer = deps.noteActionPerformerProducer.makePerformer()
        let noteReporter = deps.noteActionPerformerProducer.reporter
        let viewModel = NoteDetailsViewModelImpl(
            noteModel: noteModel,
            router: router,
            notePerformer: notePerformer,
            noteReporter: noteReporter,
            toastManager: deps.toastManager
        )
        let rootView = NoteDetailsView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        return vc
    }

    // MARK: - Private Properties

    private let deps: NoteDetailsFactoryDeps

}
