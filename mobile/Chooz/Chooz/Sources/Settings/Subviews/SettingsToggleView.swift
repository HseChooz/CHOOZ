import SwiftUI

struct SettingsToggleView: View {
    
    // MARK: - Init
    
    init(title: String) {
        self.title = title
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            HStack(spacing: 8.0) {
                Images.Icons.lock
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20.0, height: 20.0)
                
                Text(title)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey600)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Colors.Blue.blue500))
                .labelsHidden()
                .fixedSize()
        }
        .padding(.trailing, 8.0)
    }
    
    // MARK: - Private Properties
    
    private let title: String
    @State private var isOn: Bool = false
}

#Preview {
    SettingsToggleView(title: "Получать уведомления")
}
