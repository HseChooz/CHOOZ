import Foundation

enum ProfileSegment: CaseIterable, Identifiable {
    case wishlist
    case questionnaire
    
    // MARK: - Identifiable
    
    var id: Self { self }
    
    // MARK: - Internal Properties
    
    var title: String {
        switch self {
        case .wishlist: "Вишлист"
        case .questionnaire: "Анкета"
        }
    }
    
    var isAvailable: Bool {
        switch self {
        case .wishlist: true
        case .questionnaire: false
        }
    }
}
