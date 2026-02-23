import SwiftUI

struct MainActionButton: View {
    
    // MARK: - Init
    
    init(
        title: String,
        backgroundColor: Color,
        foregroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .padding(.horizontal, 15.0)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundColor(foregroundColor)
                    .lineLimit(1)
                    .frame(height: 50.0)
                    .frame(maxWidth: Layout.maxWidth.value(for: interfaceLayout))
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let maxWidth: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 350.0,
            compact: .infinity
        )
    }
    
    // MARK: - Private Properties
    
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: @MainActor () -> Void
    
    @Environment(\.interfaceLayout) private var interfaceLayout
}
