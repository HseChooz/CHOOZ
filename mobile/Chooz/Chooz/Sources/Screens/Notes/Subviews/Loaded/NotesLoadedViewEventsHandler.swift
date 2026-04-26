import Foundation

@MainActor
protocol NotesLoadedViewEventsHandler {
    func createNote()
    func openNoteDetails(noteModel: NoteModel)
    func setFavorite(noteId: String, isFavorite: Bool)
    func refreshNotes()
}
