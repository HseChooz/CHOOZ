import Foundation

enum NotesViewState {

    case loading
    case idle
    case loaded(NotesLoadedView.Model)
    case error(ScreenErrorView.Model)

}

enum NotesErrorType: Error, Equatable {

    case unknown

    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }

}
