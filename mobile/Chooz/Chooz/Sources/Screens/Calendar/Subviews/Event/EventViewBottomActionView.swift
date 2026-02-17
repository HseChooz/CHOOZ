import SwiftUI

struct EventViewBottomActionView: View {
    
    // MARK: - Init
    
    init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: action,
            label: {
                icon
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
                    .foregroundStyle(Colors.Blue.blue500)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let icon: Image
    private let action: @MainActor () -> Void
}
