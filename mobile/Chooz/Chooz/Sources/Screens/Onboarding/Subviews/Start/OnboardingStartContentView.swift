import SwiftUI

struct OnboardingStartContentView: View {
    
    // MARK: - Body
    
    var body: some View {
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
        .padding(.top, 90.0)
    }
}

#Preview {
    OnboardingStartContentView()
}

