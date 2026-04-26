import SwiftUI

struct SocialProfileView<ViewModel: SocialProfileViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.requestProfile()
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .loaded(let model):
            SocialProfileLoadedView(model: model, eventsHandler: viewModel)
        case .error(let model):
            ScreenErrorView(model: model, retryAction: viewModel.retryProfileRequest)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32.0) {
            ProfileHeaderView(model: ProfileHeaderView.Model(
                firstName: nil,
                lastName: nil,
                isLoading: true
            ))
            
            WishlistSkeletonView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
    }
    
}
