import SwiftUI

struct OnboardingWishlistContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 17.0) {
            VStack(spacing: 44.0) {
                Images.Mascotte.Curious.v3
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
                
                Text("Храните все свои желания и мечты в одном месте.")
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Common.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 51.0)
        }
        .padding(.top, 54.0)
    }
}

#Preview {
    OnboardingWishlistContentView()
}

