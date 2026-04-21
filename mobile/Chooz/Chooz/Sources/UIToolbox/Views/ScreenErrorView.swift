import SwiftUI

struct ScreenErrorView: View {
    
    // MARK: - Internal Types
    
    struct Model {
        let title: String
        let buttonTitle: String
    }
    
    // MARK: - Init
    
    init(model: Model, retryAction: @escaping () -> Void) {
        self.model = model
        self.retryAction = retryAction
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 16.0) {
                Text(model.title)
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)
            }
            
            MainActionButton(
                title: model.buttonTitle,
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: retryAction
            )
        }
        .padding(.horizontal, 52.0)
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    private let retryAction: @MainActor () -> Void
    
}
