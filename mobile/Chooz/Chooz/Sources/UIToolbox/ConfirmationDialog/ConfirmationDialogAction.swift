import Foundation

struct ConfirmationDialogAction {
    let title: String
    let action: @MainActor () -> Void
}
