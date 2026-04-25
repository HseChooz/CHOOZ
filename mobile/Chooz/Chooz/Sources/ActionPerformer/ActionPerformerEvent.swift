import Foundation

enum ActionPerformerEvent<Action: Sendable, Target: Sendable, ActionResult: Sendable>: Sendable {
    case willPerform(action: Action, target: Target)
    case didPerform(action: Action, target: Target, actionResult: ActionResult)
    case failPerform(action: Action, target: Target, error: Error)
}
