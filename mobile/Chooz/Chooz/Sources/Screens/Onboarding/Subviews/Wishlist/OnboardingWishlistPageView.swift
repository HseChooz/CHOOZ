import SwiftUI

struct OnboardingWishlistPageView: View {
    
    // MARK: - Init
    
    init(eventHandler: OnboardingPageViewEventHandler) {
        self.eventHandler = eventHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: 17.0) {
                VStack(spacing: 44.0) {
                    Images.Mascotte.curious
                        .resizable()
                        .scaledToFill()
                        .frame(width: 82.0, height: 35.0)
                    
                    Images.onboardingWishlistIcon
                        .resizable()
                        .scaledToFill()
                        .frame(width: 159.0, height: 241.1)
                }
                
                VStack(spacing: 30.0) {
                    Text("Вишлист")
                        .font(.velaSans(size: 40.0, weight: .bold))
                        .foregroundStyle(Colors.Common.black)
                    
                    Text("Храните все свои желания и\n мечты в одном месте.")
                        .font(.velaSans(size: 16.0, weight: .regular))
                        .foregroundStyle(Colors.Common.black)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 54.0)
            
            Spacer()
            
            VStack(spacing: 42.0) {
                OnboardingPageIndicatorView(
                    totalPages: 3,
                    currentPageIndex: 0
                )
                
                OnboardingActionsView(
                    model: OnboardingActionsView.Model(
                        primaryAction: eventHandler.nextPage,
                        primaryActionTitle: "Дальше",
                        skipAction: eventHandler.skip
                    )
                )
            }
        }
        .padding(.horizontal, 16.0)
    }
    
    // MARK: - Private Properties
    
    private let eventHandler: OnboardingPageViewEventHandler
}

#Preview {
    OnboardingWishlistPageView(eventHandler: OnboardingViewModel())
}
