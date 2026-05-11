import SwiftUI

struct OnboardingNotesContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 50.0) {
            Images.Onboarding.notes
                .resizable()
                .scaledToFill()
                .frame(height: 274.0)
                .padding(.leading, Static.leadingImagePadding.value(for: interfaceLayout))
            
            VStack(spacing: .zero) {
                Text("Заметки")
                    .font(.velaSans(size: 28.0, weight: .extraBold))
                    .foregroundStyle(Colors.Neutral.grey900)
                    .multilineTextAlignment(.center)
                
                Text("А также записывайте предпочтения друзей и идеи подарков")
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Common.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32.0)
        }
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let leadingImagePadding: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: .zero,
            compact: 32.0,
            small: 16.0
        )
    }
    
    // MARK: - Private Properties
    
    @Environment(\.interfaceLayout) private var interfaceLayout
}

#Preview {
    OnboardingNotesContentView()
}

