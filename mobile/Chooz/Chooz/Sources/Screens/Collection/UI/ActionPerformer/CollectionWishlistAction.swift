import Foundation

// MARK: - Action

enum CollectionWishlistAction: Sendable, Equatable {
    case add
    case remove
}

// MARK: - Performer

typealias CollectionWishlistActionPerformer = ActionPerformer<
    CollectionWishlistAction,
    String,
    Void
>

// MARK: - Reporter

typealias CollectionWishlistActionReporter = ActionReporter<
    CollectionWishlistAction,
    String,
    Void
>
