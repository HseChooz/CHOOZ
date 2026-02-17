import Foundation

enum CalendarViewState {
    case empty
    case loading
    case loaded([EventItem])
    case error
}
