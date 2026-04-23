import SwiftUI

struct ProfileButtonView: View {
    
    // MARK: - Init
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: action,
            label: {
                Images.Icons.profile
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36.0, height: 36.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let action: @MainActor () -> Void
    
}
