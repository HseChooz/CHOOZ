import Foundation

// MARK: - ActionReporter

protocol ActionReporter<Action, Target, ActionResult>: Sendable, AnyObject {

    associatedtype Action: Sendable
    associatedtype Target: Sendable
    associatedtype ActionResult: Sendable

    typealias Observer = ActionPerformerObserver<Action, Target, ActionResult>

    func addObserver(_ observer: any Observer)
    func removeObserver(_ observer: any Observer)

}

// MARK: - ActionPerformerObserver

/// Upon adding, observers immediately receive `willPerform` for all currently in-flight actions.
protocol ActionPerformerObserver<Action, Target, ActionResult>: Sendable, AnyObject {

    associatedtype Action
    associatedtype Target
    associatedtype ActionResult

    func willPerform(
        action: Action,
        for target: Target,
        in performer: any ActionPerformer<Action, Target, ActionResult>
    )

    func didPerform(
        action: Action,
        for target: Target,
        with result: ActionResult,
        in performer: any ActionPerformer<Action, Target, ActionResult>
    )

    func failPerform(
        action: Action,
        for target: Target,
        with error: Error,
        in performer: any ActionPerformer<Action, Target, ActionResult>
    )

}
