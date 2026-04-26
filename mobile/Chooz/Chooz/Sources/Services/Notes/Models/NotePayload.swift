import Foundation

struct NotePayload: Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let link: URL?
    var isFavorite: Bool
    let createdAt: String
    let updatedAt: String
}
