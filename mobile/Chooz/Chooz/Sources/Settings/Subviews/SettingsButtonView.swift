import SwiftUI

struct SettingsButtonView: View {
    
    // MARK: - Internal Types
    
    enum Style {
        case neutral
        case red
    }
    
    // MARK: - Init

    init(
        title: String,
        style: Style,
        hasChevron: Bool,
        action: @escaping @MainActor () -> Void = {}
    ) {
        self.title = title
        self.style = style
        self.hasChevron = hasChevron
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: action,
            label: {
                HStack(alignment: .center, spacing: .zero) {
                    HStack(spacing: 8.0) {
                        lockIcon
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20.0, height: 20.0)
                        
                        Text(title)
                            .font(.velaSans(size: 16.0, weight: .bold))
                            .foregroundStyle(titleColor)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if hasChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey600)
                    }
                }
                .padding(.trailing, 24.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let title: String
    private let style: Style
    private let hasChevron: Bool
    private let action: @MainActor () -> Void
    
    private var lockIcon: Image {
        switch style {
        case .neutral: Images.Icons.lock
        case .red: Images.Icons.lockRed
        }
    }
    
    private var titleColor: Color {
        switch style {
        case .neutral: Colors.Neutral.grey600
        case .red: Colors.Red.red500
        }
    }
}
