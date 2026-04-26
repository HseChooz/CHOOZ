import SwiftUI

struct NotesView<ViewModel: NotesViewModel>: View {

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        contentView
            .onAppear {
                viewModel.requestNotes()
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
            NotesIdleView(eventsHandler: viewModel)
        case .loaded(let model):
            NotesLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryNotesRequest)
        }
    }

}
