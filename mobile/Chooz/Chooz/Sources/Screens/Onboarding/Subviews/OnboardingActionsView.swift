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
            MainActionButton(
                title: primaryActionTitle,
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: primaryAction
            )
                        
            if let skipAction = skipAction {
                MainActionButton(
                    title: "Пропустить",
                    backgroundColor: Color.clear,
                    foregroundColor: Colors.Neutral.grey600,
                    action: skipAction
                )
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let primaryAction: () -> Void
    private let primaryActionTitle: String
    private let skipAction: (() -> Void)?
}
