import SwiftUI

struct OnboardingStartContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 130.0) {
            RoundedRectangle(cornerRadius: 32.0)
                .fill(Colors.Blue.blue500)
                .frame(width: 170.0, height: 170.0)
                .rotationEffect(Angle(degrees: -10.77))
                .overlay {
                    Images.Logo.Short.v3
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFill()
                        .frame(width: 95.0, height: 40.0)
                        .foregroundStyle(Colors.Common.white)
                        .rotationEffect(Angle(degrees: -10.77))
                }
            
            VStack(spacing: .zero) {
                Text("Добро пожаловать в Chooz")
                    .font(.velaSans(size: 28.0, weight: .extraBold))
                    .foregroundStyle(Colors.Neutral.grey900)
                    .multilineTextAlignment(.center)
                
                Text("Прежде чем начать, предлагаем узнать об основных функциях")
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Common.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32.0)
        }
    }
}

#Preview {
    OnboardingStartContentView()
}

