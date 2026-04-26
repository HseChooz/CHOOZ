import Foundation

enum FavoriteNotesViewState {

    case loading
    case idle
    case loaded(FavoriteNotesLoadedView.Model)
    case error(ScreenErrorView.Model)

}

enum FavoriteNotesErrorType: Error, Equatable {

    case unknown

    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }

}
