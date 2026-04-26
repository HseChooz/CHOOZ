import SwiftUI

struct FavoriteNotesView<ViewModel: FavoriteNotesViewModel>: View {

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        contentView
            .onAppear {
                viewModel.requestFavoriteNotes()
            }
    }

    // MARK: - Private Properties

    private var viewModel: ViewModel

    // MARK: - Private Views

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            NotesSkeletonView()
        case .idle:
            FavoriteNotesIdleView()
        case .loaded(let model):
            FavoriteNotesLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryFavoriteNotesRequest)
        }
    }

}
