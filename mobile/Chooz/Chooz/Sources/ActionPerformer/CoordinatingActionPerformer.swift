import Foundation

extension ActionPerformer where Target: Hashable, Action: Equatable {

    func coordinated(debounceInterval: TimeInterval = 0.2) -> CoordinatingActionPerformer<Self> {
        CoordinatingActionPerformer(
            wrappedPerformer: self,
            debounceInterval: debounceInterval
        )
    }

}

// MARK: - CoordinatingActionPerformer

/// Thread-safe decorator that provides:
/// - Debounce per target
/// - Cancellation of previous action for the same target
/// - Observer notification (willPerform / didPerform / failPerform)
actor CoordinatingActionPerformer<Performer: ActionPerformer>:
    ActionReporter,
    CancellableActionPerformer
    where Performer.Target: Hashable, Performer.Action: Equatable
{
    // MARK: - Internal Types

    typealias Action = Performer.Action
    typealias Target = Performer.Target
    typealias ActionResult = Performer.ActionResult

    // MARK: - Init

    init(wrappedPerformer: Performer, debounceInterval: TimeInterval) {
        self.wrappedPerformer = wrappedPerformer
        self.debounceInterval = debounceInterval
    }

    // MARK: - ActionPerformer

    @discardableResult
    func perform(action: Action, for target: Target) async throws -> ActionResult {
        performingActions[target]?.cancel()

        let task = Task { [weak self] in
            guard let self else { throw CancellationError() }

            try await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            try Task.checkCancellation()

            await notifyWillPerform(action: action, target: target)

            do {
                let result = try await wrappedPerformer.perform(action: action, for: target)
                try Task.checkCancellation()
                await notifyDidPerform(action: action, target: target, result: result)
                await removePerformingAction(for: target)
                return result
            } catch {
                await removePerformingAction(for: target)
                if !(error is CancellationError) {
                    await notifyFailPerform(action: action, target: target, error: error)
                }
                throw error
            }
        }

        performingActions[target] = task
        return try await task.value
    }

    // MARK: - CancellableActionPerformer

    nonisolated func cancelAllPerformingActions() {
        Task { await _cancelAllPerformingActions() }
    }

    // MARK: - ActionReporter

    nonisolated func addObserver(_ observer: any Observer) {
        Task { await _addObserver(observer) }
    }

    nonisolated func removeObserver(_ observer: any Observer) {
        Task { await _removeObserver(observer) }
    }

    // MARK: - Private Properties

    private let wrappedPerformer: Performer
    private let debounceInterval: TimeInterval
    private var performingActions: [Target: Task<ActionResult, Error>] = [:]
    private var observers = WeakArray<AnyObject>()

    // MARK: - Private Methods

    private func _cancelAllPerformingActions() {
        for task in performingActions.values {
            task.cancel()
        }
        performingActions.removeAll()
    }

    private func _addObserver(_ observer: any Observer) {
        observers.append(observer)
    }

    private func _removeObserver(_ observer: any Observer) {
        observers.remove(observer)
    }

    private func notifyWillPerform(action: Action, target: Target) {
        for observer in typedObservers {
            observer.willPerform(action: action, for: target, in: self)
        }
    }

    private func notifyDidPerform(action: Action, target: Target, result: ActionResult) {
        for observer in typedObservers {
            observer.didPerform(action: action, for: target, with: result, in: self)
        }
    }

    private func notifyFailPerform(action: Action, target: Target, error: Error) {
        for observer in typedObservers {
            observer.failPerform(action: action, for: target, with: error, in: self)
        }
    }

    private func removePerformingAction(for target: Target) {
        performingActions[target] = nil
    }

    private var typedObservers: [any Observer] {
        observers.elements.compactMap { $0 as? any Observer }
    }

}
