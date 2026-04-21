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
            .toolbar {
                MainTabToolbarContent(eventsHandler: viewModel)
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
