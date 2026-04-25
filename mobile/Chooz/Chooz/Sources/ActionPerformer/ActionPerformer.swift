import Foundation

protocol ActionPerformer<Action, Target, ActionResult>: Sendable, AnyObject {

    associatedtype Action: Sendable
    associatedtype Target: Sendable
    associatedtype ActionResult: Sendable

    @discardableResult
    func perform(action: Action, for target: Target) async throws -> ActionResult

}
