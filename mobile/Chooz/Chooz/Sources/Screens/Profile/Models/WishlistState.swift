import Foundation

enum WishlistState {
    case empty
    case loading
    case loaded([WishlistItem])
    case error
}
