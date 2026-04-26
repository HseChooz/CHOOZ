import Foundation

@MainActor
protocol FavoriteNotesLoadedViewEventsHandler {
    func createNote()
    func openNoteDetails(noteModel: NoteModel)
    func setFavorite(noteId: String, isFavorite: Bool)
    func refreshFavoriteNotes()
}
