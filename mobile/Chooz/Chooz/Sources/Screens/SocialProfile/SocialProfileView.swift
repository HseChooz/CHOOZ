import SwiftUI

struct SocialProfileView: View {
    
    // MARK: - Init
    
    init(viewModel: SocialProfileViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 32.0) {
            ProfileHeaderView(model: viewModel.headerModel)
            
            VStack(spacing: .zero) {
                ProfileSegmentPickerView(
                    segments: ProfileSegment.allCases,
                    selectedSegment: $viewModel.selectedSegment
                )
                
                contentView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContentView
        }
        .task {
            await viewModel.fetchWishItems()
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable
    private var viewModel: SocialProfileViewModel
    
    // MARK: - Private Views
    
    @ToolbarContentBuilder
    private var toolbarContentView: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            backButtonView
        }
    }
    
    private var backButtonView: some View {
        Button(action: viewModel.onClose) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17.0, weight: .semibold))
                .foregroundStyle(Colors.Neutral.grey800)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedSegment {
        case .wishlist:
            SocialWishlistContentView(
                state: viewModel.wishlistState,
                onRetry: { Task { await viewModel.fetchWishItems() } }
            )
        case .questionnaire:
            EmptyView()
        }
    }
}
