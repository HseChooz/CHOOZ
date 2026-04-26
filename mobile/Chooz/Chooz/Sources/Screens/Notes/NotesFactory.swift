import Foundation
import SwiftUI

@MainActor
struct NotesFactory {

    // MARK: - Init

    init(deps: NotesFactoryDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makeView() -> some View {
        let router = NotesRouter(deps: deps)
        let interactor = NotesInteractor(deps: deps, onlyFavorites: false)
        let viewStateBuilder = NotesViewStateBuilder()
        let notePerformer = deps.noteActionPerformerProducer.makePerformer()
        let noteReporter = deps.noteActionPerformerProducer.reporter
        let analytics = NotesAnalytics(analyticsService: deps.analyticsService)
        let viewModel = NotesViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: viewStateBuilder,
            notePerformer: notePerformer,
            noteReporter: noteReporter,
            analytics: analytics
        )
        let view = NotesView(viewModel: viewModel)
        return view
    }

    // MARK: - Private Properties

    private let deps: NotesFactoryDeps

}
