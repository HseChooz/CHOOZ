import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Init
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $viewModel.currentPageIndex) {
            Text("\(viewModel.currentPageIndex)")
                .font(.largeTitle)
            
            Spacer()
            
            VStack(spacing: 10.0) {
                Button(
                    action: {
                        viewModel.incrementPageIndex()
                    },
                    label: {
                        Text("Increment")
                    }
                )
                
                Button(
                    action: {
                        viewModel.decrementPageIndex()
                    },
                    label: {
                        Text("Decrement")
                    }
                )
            }
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable
    private var viewModel: OnboardingViewModel
}
