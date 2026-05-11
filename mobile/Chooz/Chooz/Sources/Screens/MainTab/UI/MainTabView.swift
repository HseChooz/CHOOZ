import SwiftUI

struct MainTabView<ViewModel: MainTabViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                 viewModel.requestSections()
            }
            .safeAreaInset(edge: .top) {
                HStack(spacing: 24.0) {
                    MainTabSearchBarView(
                        searchText: Binding(
                            get: { viewModel.searchText },
                            set: { viewModel.searchText = $0 }
                        )
                    )
                                    
                    ProfileButtonView(action: viewModel.openProfile)
                }
                .padding(.horizontal, 16.0)
            }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            MainTabSkeletonView()
        case .loaded(let model):
            MainTabLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retrySectionsRequest)
        }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
}
