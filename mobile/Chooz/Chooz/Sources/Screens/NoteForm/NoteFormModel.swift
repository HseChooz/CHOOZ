import Foundation

struct NoteFormModel: Equatable, Sendable {

    let id: String?
    var title: String
    var description: String
    var link: String

    init(
        id: String? = nil,
        title: String = "",
        description: String = "",
        link: String = ""
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.link = link
    }

}
