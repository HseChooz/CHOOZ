import Foundation

enum WishlistMutationErrorMessage {
    
    // MARK: - Internal
    
    static func presentation(for error: Error) -> (title: String, subtitle: String?) {
        if let urlError = error as? URLError {
            return presentation(for: urlError)
        }
        
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorDataNotAllowed:
                return ("Нет подключения к сети", "Проверьте интернет и попробуйте снова")
            case NSURLErrorTimedOut:
                return ("Сервер не отвечает", "Попробуйте ещё раз позже")
            case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
                return ("Не удалось подключиться", "Попробуйте ещё раз позже")
            default:
                break
            }
        }
        
        let raw = ns.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()
        
        if lower.contains("numeric") && (lower.contains("overflow") || lower.contains("out of range") || lower.contains("too many digits")) {
            return ("Некорректная цена", "Укажите меньшую сумму")
        }
        
        if raw.isEmpty {
            return ("Что-то пошло не так", "Попробуйте ещё раз позже")
        }
        
        if looksLikeTechnicalMessage(raw) {
            return ("Что-то пошло не так", "Попробуйте ещё раз позже")
        }
        
        return (raw, nil)
    }
    
    // MARK: - Private
    
    private static func presentation(for urlError: URLError) -> (title: String, subtitle: String?) {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return ("Нет подключения к сети", "Проверьте интернет и попробуйте снова")
        case .timedOut:
            return ("Сервер не отвечает", "Попробуйте ещё раз позже")
        case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return ("Не удалось подключиться", "Попробуйте ещё раз позже")
        default:
            return ("Что-то пошло не так", "Попробуйте ещё раз позже")
        }
    }
    
    private static func looksLikeTechnicalMessage(_ raw: String) -> Bool {
        if raw.count > 200 {
            return true
        }
        let lower = raw.lowercased()
        if lower.contains("apollo") || lower.contains("graphql") {
            return true
        }
        if lower.contains("response code") || lower.contains("status code") {
            return true
        }
        if lower.contains("json") && lower.contains("could not") {
            return true
        }
        return false
    }
}
