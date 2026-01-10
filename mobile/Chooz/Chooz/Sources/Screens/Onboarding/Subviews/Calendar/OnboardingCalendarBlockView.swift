import SwiftUI

struct OnboardingCalendarBlockView: View {
    
    // MARK: - Init
    
    init(day: String, accentColor: Color) {
        self.day = day
        self.accentColor = accentColor
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            VStack(alignment: .center, spacing: .zero) {
                RoundedRectangle(cornerRadius: 1.0)
                    .fill(Colors.Neutral.grey400)
                    .frame(width: 19.0, height: 7.0)
                
                Text(day)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Blue.blue500)
            }
            
            Rectangle()
                .fill(Colors.Blue.blue500)
                .frame(width: 2.0 * pixelLength)
            
            VStack(alignment: .leading, spacing: 11.0) {
                RoundedRectangle(cornerRadius: 1.0)
                    .fill(Colors.Blue.blue500)
                    .frame(height: 7.0)
                
                RoundedRectangle(cornerRadius: 3.0)
                    .fill(accentColor)
                    .frame(width: 56.0, height: 10.0)
            }
        }
        .padding(EdgeInsets(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 15.0))
        .frame(width: 203.0, height: 49.0)
        .background(Colors.Common.white)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .strokeBorder(Colors.Blue.blue500, lineWidth: 1.0)
        )
    }
    
    // MARK: - Private Properties
    
    @Environment(\.pixelLength)
    private var pixelLength
    
    private let day: String
    private let accentColor: Color
}

#Preview {
    OnboardingCalendarBlockView(day: "1", accentColor: Colors.Blue.blue500)
}
