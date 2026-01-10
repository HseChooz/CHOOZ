import SwiftUI

struct OnboardingPageContainerView<Content: View>: View {
    
    // MARK: - Init
    
    init(
        viewModel: OnboardingViewModel,
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = viewModel
        self.content = content()
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            content
            
            Spacer()
            
            bottomView
        }
        .padding(.horizontal, 16.0)
    }
    
    // MARK: - Private Properties
    
    private let viewModel: OnboardingViewModel
    private let content: Content
    
    // MARK: - Private Views
    
    private var bottomView: some View {
        VStack(spacing: 42.0) {
            if viewModel.showsIndicator {
                OnboardingPageIndicatorView(
                    totalPages: viewModel.indicatorTotalPages,
                    currentPageIndex: viewModel.indicatorCurrentIndex
                )
            }
            
            OnboardingActionsView(
                primaryAction: viewModel.nextPage,
                primaryActionTitle: viewModel.primaryButtonTitle,
                skipAction: viewModel.showsSkipButton ? { viewModel.skip() } : nil
            )
        }
    }
}

