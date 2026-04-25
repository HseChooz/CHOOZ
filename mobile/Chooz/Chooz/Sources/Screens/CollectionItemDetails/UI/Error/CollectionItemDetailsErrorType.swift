import Foundation

enum CollectionItemDetailsErrorType: Error, Equatable {
    
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Не удалось загрузить желание"
        }
    }
    
}
