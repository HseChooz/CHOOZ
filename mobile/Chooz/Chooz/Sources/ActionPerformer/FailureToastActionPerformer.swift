import Foundation

extension ActionPerformer {

    func withFailureToast(toastManager: ToastManager) -> some ActionPerformer<Action, Target, ActionResult> {
        FailureToastActionPerformer(performer: self, toastManager: toastManager)
    }

}

// MARK: - FailureToastActionPerformer

final class FailureToastActionPerformer<Performer: ActionPerformer>: ActionPerformer {

    // MARK: - Internal Types

    typealias Action = Performer.Action
    typealias Target = Performer.Target
    typealias ActionResult = Performer.ActionResult

    // MARK: - Init

    fileprivate init(performer: Performer, toastManager: ToastManager) {
        self.performer = performer
        self.toastManager = toastManager
    }

    // MARK: - Internal Methods

    @discardableResult
    func perform(action: Action, for target: Target) async throws -> ActionResult {
        do {
            return try await performer.perform(action: action, for: target)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            await toastManager.showError("Что-то пошло не так", subtitle: "Попробуйте ещё раз позже")
            throw error
        }
    }

    // MARK: - Private Properties

    private let performer: Performer
    private let toastManager: ToastManager

}
