import Foundation
import SwiftUI

@MainActor
struct FavoriteNotesFactory {

    // MARK: - Init

    init(deps: FavoriteNotesFactoryDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makeView() -> some View {
        let router = FavoriteNotesRouter(deps: deps)
        let interactor = NotesInteractor(deps: deps, onlyFavorites: true)
        let viewStateBuilder = NotesViewStateBuilder()
        let notePerformer = deps.noteActionPerformerProducer.makePerformer()
        let noteReporter = deps.noteActionPerformerProducer.reporter
        let analytics = FavoriteNotesAnalytics(analyticsService: deps.analyticsService)
        let viewModel = FavoriteNotesViewModelImpl(
            interactor: interactor,
            router: router,
            viewStateBuilder: viewStateBuilder,
            notePerformer: notePerformer,
            noteReporter: noteReporter,
            analytics: analytics
        )
        let view = FavoriteNotesView(viewModel: viewModel)
        return view
    }

    // MARK: - Private Properties

    private let deps: FavoriteNotesFactoryDeps

}
