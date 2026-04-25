import SwiftUI

struct CollectionItemDetailsView<ViewModel: CollectionItemDetailsViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.requestCollectionItemDetails()
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            CollectionItemDetailsSkeletonView()
        case .loaded(let model):
            CollectionItemDetailsLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryCollectionItemDetailsRequest)
        }
    }
    
}
