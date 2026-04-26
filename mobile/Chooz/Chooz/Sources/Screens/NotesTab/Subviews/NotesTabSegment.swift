import Foundation

enum NotesTabSegment: CaseIterable, Identifiable {
    
    case allNotes
    case favoriteNotes
    
    // MARK: - Identifiable
    
    var id: Self { self }
    
    // MARK: - Internal Properties
    
    var title: String {
        switch self {
        case .allNotes: "Все заметки"
        case .favoriteNotes: "Избранное"
        }
    }
    
}
