import Foundation

enum NoteFormError: Error, Equatable {
    case invalidLink

    var title: String {
        switch self {
        case .invalidLink:
            return "Некорректная ссылка"
        }
    }

    var subtitle: String? {
        switch self {
        case .invalidLink:
            return nil
        }
    }
}
