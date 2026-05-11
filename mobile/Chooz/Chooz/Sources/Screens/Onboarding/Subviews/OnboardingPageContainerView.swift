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
        VStack(spacing: 16.0) {
            content
            
            bottomView
                .padding(.horizontal, 32.0)
        }
        .padding(.top, 16.0)
        .padding(.bottom, 16.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
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

