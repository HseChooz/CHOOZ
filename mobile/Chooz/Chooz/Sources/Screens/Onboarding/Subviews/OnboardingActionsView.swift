import SwiftUI

struct OnboardingActionsView: View {
    
    // MARK: - Init
    
    init(
        primaryAction: @escaping () -> Void,
        primaryActionTitle: String,
        skipAction: (() -> Void)?
    ) {
        self.primaryAction = primaryAction
        self.primaryActionTitle = primaryActionTitle
        self.skipAction = skipAction
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 1.0) {
            Button(
                action: primaryAction,
                label: {
                    Text(primaryActionTitle)
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Common.white)
                }
            )
            .buttonStyle(ScaleButtonStyle())
            .padding(.vertical, 10.0)
            .padding(.horizontal, 16.0)
            .frame(minHeight: 50.0)
            .frame(maxWidth: .infinity)
            .background(Colors.Blue.blue500)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        
            if let skipAction = skipAction {
                Button(
                    action: skipAction,
                    label: {
                        Text("Пропустить")
                            .font(.velaSans(size: 16.0, weight: .semiBold))
                            .foregroundStyle(Colors.Neutral.grey600)
                    }
                )
                .buttonStyle(ScaleButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let primaryAction: () -> Void
    private let primaryActionTitle: String
    private let skipAction: (() -> Void)?
}
