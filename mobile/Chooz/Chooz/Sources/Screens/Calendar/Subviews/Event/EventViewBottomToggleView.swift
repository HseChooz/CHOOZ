import SwiftUI

struct EventViewBottomToggleView: View {
    
    // MARK: - Init
    
    init(
        icon: Image,
        activeIcon: Image,
        isActive: Bool,
        onToggle: @escaping (Bool) -> Void
    ) {
        self.icon = icon
        self.activeIcon = activeIcon
        self.isActive = isActive
        self.onToggle = onToggle
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                onToggle(!isActive)
            },
            label: {
                (isActive ? activeIcon : icon)
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
    private let activeIcon: Image
    private let isActive: Bool
    private let onToggle: @MainActor (Bool) -> Void
}
