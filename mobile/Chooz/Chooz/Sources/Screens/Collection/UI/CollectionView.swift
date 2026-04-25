import SwiftUI

struct CollectionView<ViewModel: CollectionViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.requestCollection()
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            CollectionSkeletonView()
        case .loaded(let model):
            CollectionLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryCollectionRequest)
        }
    }
    
}
