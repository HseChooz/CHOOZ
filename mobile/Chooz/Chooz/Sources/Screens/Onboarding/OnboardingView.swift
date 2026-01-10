import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Init
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        OnboardingPageContainerView(viewModel: viewModel) {
            pageContent
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    // MARK: - Private Properties
    
    private var viewModel: OnboardingViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var pageContent: some View {
        switch viewModel.currentPage {
        case .start:
            OnboardingStartContentView()
        case .wishlist:
            OnboardingWishlistContentView()
        case .calendar:
            OnboardingCalendarContentView()
        case .finish:
            OnboardingFinishContentView()
        }
    }
}
