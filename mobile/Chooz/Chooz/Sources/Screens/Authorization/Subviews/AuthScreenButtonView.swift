import SwiftUI

struct AuthScreenButtonView: View {
    
    // MARK: - Internal Types
    
    enum Style {
        case primary
        case secondary
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Colors.Blue.blue500
            case .secondary:
                return Colors.Neutral.grey200
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return Colors.Common.white
            case .secondary:
                return Colors.Neutral.grey800
            }
        }
    }
    
    // MARK: - Init
    
    init(
        image: Image,
        title: String,
        style: Style,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.style = style
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 10.0) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20.0, height: 20.0)
                    
                    Text(title)
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(style.foregroundColor)
                }
                .padding(.vertical, 10.0)
                .padding(.horizontal, 16.0)
                .frame(minHeight: 50.0)
                .frame(maxWidth: Layout.maxWidth.value(for: interfaceLayout))
                .background(style.backgroundColor)
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
    
    private let image: Image
    private let title: String
    private let style: Style
    private let action: () -> Void
    
    @Environment(\.interfaceLayout) private var interfaceLayout
}
