import SwiftUI

struct CollectionsListView<ViewModel: CollectionsListViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.requestCollectionsList()
            }
            .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            CollectionsListSkeletonView()
        case .loaded(let model):
            CollectionsListLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryCollectionsListRequest)
        }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
}
