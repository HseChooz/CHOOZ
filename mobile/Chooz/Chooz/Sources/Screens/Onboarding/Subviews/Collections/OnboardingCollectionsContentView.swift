import SwiftUI

struct OnboardingCollectionsContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 50.0) {
            Images.Onboarding.collections
                .resizable()
                .scaledToFill()
                .frame(width: 249.0, height: 352.0)
            
            VStack(spacing: .zero) {
                Text("Подборки")
                    .font(.velaSans(size: 28.0, weight: .extraBold))
                    .foregroundStyle(Colors.Neutral.grey900)
                    .multilineTextAlignment(.center)
                
                Text("Выбирайте товары из подборок на основе ваших предпочтений")
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Common.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32.0)
        }
    }
}

#Preview {
    OnboardingCollectionsContentView()
}

