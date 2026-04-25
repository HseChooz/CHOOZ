import Foundation

enum CollectionErrorType: Error, Equatable {
    
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Подборка не найдена"
        case .unknown:
            return "Не удалось загрузить подборку"
        }
    }
    
}
