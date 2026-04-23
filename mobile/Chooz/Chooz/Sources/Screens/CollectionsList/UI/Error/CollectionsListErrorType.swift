import Foundation

enum CollectionsListErrorType: Error, Equatable {
    
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }
    
}
