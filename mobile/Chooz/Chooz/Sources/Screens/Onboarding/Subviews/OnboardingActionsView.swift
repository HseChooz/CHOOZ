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
        VStack(alignment: .center, spacing: 8.0) {
            MainActionButton(
                title: primaryActionTitle,
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: primaryAction
            )
                        
            if let skipAction = skipAction {
                MainActionButton(
                    title: "Пропустить",
                    backgroundColor: Colors.Neutral.grey200,
                    foregroundColor: Colors.Neutral.grey800,
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
