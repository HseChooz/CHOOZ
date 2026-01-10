import SwiftUI

struct OnboardingFinishContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 76.0) {
            Images.Icons.flowerShape
                .resizable()
                .scaledToFill()
                .frame(width: 190.0, height: 190.0)
                .overlay {
                    Images.Mascotte.Shy.v1
                        .resizable()
                        .scaledToFill()
                        .frame(width: 118.0, height: 50.0)
                }
            
            VStack(spacing: 30.0) {
                Text("Пока всё...")
                    .font(.velaSans(size: 40.0, weight: .bold))
                    .foregroundStyle(Colors.Common.black)
                
                Text("Это были основные функции нашей самой первой версии приложения.\nДальше - больше!")
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Common.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 67.0)
            }
            
        }
        .padding(.top, 100.0)
    }
}

#Preview {
    OnboardingFinishContentView()
}

