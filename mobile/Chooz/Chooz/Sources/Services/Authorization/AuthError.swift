import Foundation

enum AuthError: Error {
    case cancelled
    case noConnection
    case serverOverloaded
    case serverNotResponding
    case accountDeleted
    case unknown
    
    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }
    
    var toastContent: (title: String, subtitle: String)? {
        switch self {
        case .cancelled:
            return nil
        case .noConnection:
            return ("Отсутствует подключение", "Убедитесь, что устройство подключено к Интернету")
        case .serverOverloaded:
            return ("Сервер перегружен", "Попробуйте еще раз позже")
        case .serverNotResponding:
            return ("Сервер не отвечает", "Попробуйте еще раз позже")
        case .accountDeleted:
            return ("Ваш аккаунт удален", "Все ваши данные были стерты")
        case .unknown:
            return ("Что-то пошло не так", "Произошла непредвиденная ошибка")
        }
    }
}
