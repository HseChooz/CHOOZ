import Foundation

enum MainTabErrorType: Error, Equatable {
    
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Произошла неизвестная ошибка"
        }
    }
    
}
