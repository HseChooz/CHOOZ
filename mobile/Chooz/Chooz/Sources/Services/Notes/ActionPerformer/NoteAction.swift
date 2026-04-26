import Foundation

enum NoteAction: Sendable, Equatable {
    case create(NoteFormModel)
    case update(NoteFormModel)
    case setFavorite(Bool)
    case delete
}

enum NoteActionTarget: Hashable, Sendable {
    case create
    case note(String)
}

enum NoteActionResult: Sendable {
    case note(NotePayload)
    case deleted
}

typealias NoteActionPerformer = ActionPerformer<
    NoteAction,
    NoteActionTarget,
    NoteActionResult
>

typealias NoteActionReporter = ActionReporter<
    NoteAction,
    NoteActionTarget,
    NoteActionResult
>
