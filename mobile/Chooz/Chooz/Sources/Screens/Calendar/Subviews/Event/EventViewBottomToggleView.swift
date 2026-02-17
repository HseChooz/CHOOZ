import SwiftUI

struct EventViewBottomToggleView: View {
    
    // MARK: - Init
    
    init(
        icon: Image,
        activeIcon: Image,
        isActive: Binding<Bool>,
        action: @escaping (Bool) -> Void
    ) {
        self.icon = icon
        self.activeIcon = activeIcon
        self._isActive = isActive
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: {
                isActive.toggle()
                action(isActive)
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
    @Binding private var isActive: Bool
    private let action: @MainActor (Bool) -> Void
}
