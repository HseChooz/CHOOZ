import Foundation

enum WishCurrency: CaseIterable, Identifiable {
    case rub
    case usd
    case eur
    case byn
    case kzt
    case jpy
    case krw
    case try_
    case aed
    case ils
    case uzs
    case kgs
    case gbp
    case chf
    case uah
    case pln
    
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
