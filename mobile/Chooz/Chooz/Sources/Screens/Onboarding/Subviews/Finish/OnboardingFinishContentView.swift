import SwiftUI

struct OnboardingFinishContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 50.0) {
            ZStack(alignment: .bottom) {
                Circle()
                    .fill(Colors.Pink.pink500)
                    .frame(width: 187.0)
                    .overlay {
                        Images.Mascotte.Substract.v1
                            .resizable()
                            .scaledToFill()
                            .frame(width: 111.0, height: 47.0)
                            .rotationEffect(Angle(degrees: -13.53))
                    }
                    .padding(.leading, 134.0)
                    .padding(.bottom, 160.0)
                
                Circle()
                    .fill(Colors.Green.green1B)
                    .frame(width: 240.0)
                    .overlay {
                        Images.Mascotte.Joyful.v1
                            .resizable()
                            .scaledToFill()
                            .frame(width: 127.0, height: 54.0)
                            .rotationEffect(Angle(degrees: 8.77))
                    }
                    .padding(.trailing, 118.0)
            }
            .frame(height: 400)
            
            VStack(spacing: .zero) {
                Text("И еще один шаг")
                    .font(.velaSans(size: 28.0, weight: .extraBold))
                    .foregroundStyle(Colors.Neutral.grey900)
                    .multilineTextAlignment(.center)
                
                Text("Перед тем как погрузиться в мир радости, зарегистрируйтесь")
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
    OnboardingFinishContentView()
}

