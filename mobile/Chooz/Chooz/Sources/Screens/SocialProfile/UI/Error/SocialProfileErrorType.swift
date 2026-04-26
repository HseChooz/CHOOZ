import Foundation

enum SocialProfileErrorType: Error {
    
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Профиль не найден"
        case .unknown:
            return "Не удалось загрузить профиль"
        }
    }
    
}
