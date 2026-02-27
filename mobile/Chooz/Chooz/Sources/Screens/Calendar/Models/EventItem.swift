import Foundation

struct EventItem: Hashable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let link: URL?
    let notifyEnabled: Bool
    let repeatYearly: Bool
    let date: Date

    // MARK: - Internal Properties

    var dayString: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    var daysRemainingString: String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfEvent = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfEvent).day ?? 0

        if days == 0 {
            return "сегодня"
        }

        let remainder10 = days % 10
        let remainder100 = days % 100

        let form: String
        if remainder100 >= 11, remainder100 <= 19 {
            form = "дней"
        } else if remainder10 == 1 {
            form = "день"
        } else if remainder10 >= 2, remainder10 <= 4 {
            form = "дня"
        } else {
            form = "дней"
        }

        return "через \(days) \(form)"
    }

    var fullDateString: String {
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let monthName: String
        switch month {
        case 1: monthName = "января"
        case 2: monthName = "февраля"
        case 3: monthName = "марта"
        case 4: monthName = "апреля"
        case 5: monthName = "мая"
        case 6: monthName = "июня"
        case 7: monthName = "июля"
        case 8: monthName = "августа"
        case 9: monthName = "сентября"
        case 10: monthName = "октября"
        case 11: monthName = "ноября"
        case 12: monthName = "декабря"
        default: monthName = ""
        }
        return "\(day) \(monthName)"
    }

    var shortMonthString: String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 1: return "Янв"
        case 2: return "Фев"
        case 3: return "Мар"
        case 4: return "Апр"
        case 5: return "Май"
        case 6: return "Июн"
        case 7: return "Июл"
        case 8: return "Авг"
        case 9: return "Сен"
        case 10: return "Окт"
        case 11: return "Ноя"
        case 12: return "Дек"
        default: return ""
        }
    }
}
