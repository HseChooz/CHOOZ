import SwiftUI

struct OnboardingCalendarContentView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 63.0) {
            VStack(spacing: 82.0) {
                Images.Mascotte.Curious.v3
                    .resizable()
                    .scaledToFill()
                    .frame(width: 82.0, height: 35.0)
                
                VStack(spacing: 5.0) {
                    OnboardingCalendarBlockView(
                        day: "1",
                        accentColor: Colors.RedOrange.redOrange400
                    )
                    
                    OnboardingCalendarBlockView(
                        day: "12",
                        accentColor: Colors.Blue.blue300
                    )
                    
                    OnboardingCalendarBlockView(
                        day: "31",
                        accentColor: Colors.Blue.blue300
                    )
                }
            }
            
            VStack(spacing: 30.0) {
                Text("Календарь")
                    .font(.velaSans(size: 40.0, weight: .bold))
                    .foregroundStyle(Colors.Common.black)
                
                Text("А также можно хранить в одном месте и важные события. Мы обзятельно будем напоминать Вам о них!")
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
    OnboardingCalendarContentView()
}

