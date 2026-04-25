import Foundation

protocol CancellableActionPerformer: ActionPerformer {
    func cancelAllPerformingActions()
}
