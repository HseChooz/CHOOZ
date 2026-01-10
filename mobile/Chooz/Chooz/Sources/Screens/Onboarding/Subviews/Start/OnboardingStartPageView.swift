import SwiftUI

struct OnboardingStartPageView: View {
    
    // MARK: - Init
    
    init(eventHandler: OnboardingPageViewEventHandler) {
        self.eventHandler = eventHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: 101.0) {
                Images.Logo.Short.v3
                    .resizable()
                    .scaledToFill()
                    .frame(width: 118.0, height: 50.0)
                
                VStack(spacing: 54.0) {
                    Text("Привет!")
                        .font(.velaSans(size: 48.0, weight: .extraBold))
                        .foregroundStyle(Colors.Blue.blue500)
                    
                    Text("Рады Вас видеть!\nДавайте расскажем Вам немного о\nприложении?")
                        .font(.velaSans(size: 16.0, weight: .regular))
                        .foregroundStyle(Colors.Common.black)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 150.0)
            
            Spacer()
            
            OnboardingActionsView(
                model: OnboardingActionsView.Model(
                    primaryAction: eventHandler.nextPage,
                    primaryActionTitle: "Поехали!",
                    skipAction: eventHandler.skip
                )
            )
        }
        .padding(.horizontal, 16.0)
    }
    
    // MARK: - Private Properties
    
    private let eventHandler: OnboardingPageViewEventHandler
}

#Preview {
    OnboardingStartPageView(eventHandler: OnboardingViewModel())
}
