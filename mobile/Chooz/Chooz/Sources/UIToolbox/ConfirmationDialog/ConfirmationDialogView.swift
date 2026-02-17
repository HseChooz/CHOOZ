import SwiftUI

struct ConfirmationDialogView: View {
    
    // MARK: - Init
    
    init(
        title: String,
        description: String? = nil,
        primaryAction: ConfirmationDialogAction,
        destructiveAction: ConfirmationDialogAction,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.primaryAction = primaryAction
        self.destructiveAction = destructiveAction
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16.0) {
            headerView
            
            buttonsView
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 20.0)
        .frame(maxWidth: Layout.maxWidth.value(for: interfaceLayout))
        .background(Colors.Common.white)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .padding(.horizontal, 32.0)
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let maxWidth: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 440.0,
            compact: .infinity
        )
    }
    
    // MARK: - Private Properties
    
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    private let title: String
    private let description: String?
    private let primaryAction: ConfirmationDialogAction
    private let destructiveAction: ConfirmationDialogAction
    private let onDismiss: @MainActor () -> Void
    
    // MARK: - Private Views
    
    private var headerView: some View {
        HStack(alignment: .top, spacing: 12.0) {
            VStack(alignment: .leading, spacing: 8.0) {
                Text(title)
                    .font(.velaSans(size: 20.0, weight: .bold))
                    .foregroundStyle(Colors.Common.black)
                
                if let description, !description.isEmpty {
                    Text(description)
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey600)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(
                action: onDismiss,
                label: {
                    Images.Icons.crossLarge
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    private var buttonsView: some View {
        VStack(spacing: 8.0) {
            primaryButtonView
            
            destructiveButtonView
        }
    }
    
    private var primaryButtonView: some View {
        Button(
            action: {
                onDismiss()
                primaryAction.action()
            },
            label: {
                Text(primaryAction.title)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Common.white)
                    .frame(height: 50.0)
                    .frame(maxWidth: .infinity)
                    .background(Colors.Neutral.grey800)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var destructiveButtonView: some View {
        Button(
            action: {
                onDismiss()
                destructiveAction.action()
            },
            label: {
                Text(destructiveAction.title)
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(Colors.Common.white)
                    .frame(height: 50.0)
                    .frame(maxWidth: .infinity)
                    .background(Colors.Red.red500)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
}
