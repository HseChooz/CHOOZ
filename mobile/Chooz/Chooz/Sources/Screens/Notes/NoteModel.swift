import Foundation

struct NoteModel: Hashable {
    let id: String
    let title: String
    let description: String
    let url: URL?
    var isFavorite: Bool
}
