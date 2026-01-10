import SwiftUI

@MainActor
struct OnboardingScreenFactory {
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let viewModel = OnboardingViewModel()
        let view = OnboardingView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
}
