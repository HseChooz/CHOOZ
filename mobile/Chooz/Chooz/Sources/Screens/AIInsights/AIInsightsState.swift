import Foundation

enum AIInsightsState: Equatable {
    case loading
    case generating
    case completed
    case error(String)
    case emptyWishlist
    case modelNotAvailable
    case languageNotSupported
}
