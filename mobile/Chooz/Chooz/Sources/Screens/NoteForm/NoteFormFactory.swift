import Foundation
import SwiftUI
import UIKit

@MainActor
struct NoteFormFactory {

    // MARK: - Init

    init(deps: NoteFormFactoryDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makeScreen(
        with formType: NoteFormType,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter
    ) -> UIViewController {
        let analytics = NoteFormAnalytics(analyticsService: deps.analyticsService)
        let viewModel = NoteFormViewModelBuilder.makeViewModel(
            with: formType,
            notePerformer: notePerformer,
            toastManager: deps.toastManager,
            analytics: analytics
        )
        _ = noteReporter
        let rootView = NoteFormView(viewModel: viewModel)
        let vc = UIHostingController(rootView: rootView)
        return vc
    }

    // MARK: - Private Properties

    private let deps: NoteFormFactoryDeps

}
