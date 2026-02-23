import Foundation

enum WishCurrency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    case byn = "BYN"
    case kzt = "KZT"
    case jpy = "JPY"
    case krw = "KRW"
    case try_ = "TRY"
    case aed = "AED"
    case ils = "ILS"
    case uzs = "UZS"
    case kgs = "KGS"
    case gbp = "GBP"
    case chf = "CHF"
    case uah = "UAH"
    case pln = "PLN"
    
    // MARK: - Identifiable
    
    var id: Self { self }
    
    // MARK: - Internal Properties
    
    var title: String {
        switch self {
        case .rub: "Рубль (RU)"
        case .usd: "Доллар (US)"
        case .eur: "Евро (EU)"
        case .byn: "Рубль (BEL)"
        case .kzt: "Тенге (KZ)"
        case .jpy: "Иена (JP)"
        case .krw: "Вон (KZ)"
        case .try_: "Лира (TR)"
        case .aed: "Дирхам (UAE)"
        case .ils: "Шекель (IS)"
        case .uzs: "Сум (UZ)"
        case .kgs: "Сом (KGZ)"
        case .gbp: "Фунт (UK)"
        case .chf: "Франк (CHF)"
        case .uah: "Гривна (UA)"
        case .pln: "Злотый (PL)"
        }
    }
    
    var symbol: String {
        switch self {
        case .rub: "₽"
        case .usd: "$"
        case .eur: "€"
        case .byn: "Br"
        case .kzt: "₸"
        case .jpy: "¥"
        case .krw: "₩"
        case .try_: "₺"
        case .aed: "د.إ"
        case .ils: "₪"
        case .uzs: "сўм"
        case .kgs: "с"
        case .gbp: "£"
        case .chf: "CHF"
        case .uah: "₴"
        case .pln: "zł"
        }
    }
}
