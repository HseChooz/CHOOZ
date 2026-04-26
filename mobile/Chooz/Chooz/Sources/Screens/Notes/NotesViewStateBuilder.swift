import Foundation

@MainActor
struct NotesViewStateBuilder {

    // MARK: - Internal Methods

    func buildNotesLoadedContentViewState(from notes: [NotePayload]) -> NotesLoadedView.Model {
        NotesLoadedView.Model(notes: notes.map(makeNoteRowModel))
    }

    func buildFavoriteNotesLoadedContentViewState(from notes: [NotePayload]) -> FavoriteNotesLoadedView.Model {
        FavoriteNotesLoadedView.Model(notes: notes.map(makeNoteRowModel))
    }

    func buildNotesErrorViewState(from error: NotesErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }

    func buildFavoriteNotesErrorViewState(from error: FavoriteNotesErrorType) -> ScreenErrorView.Model {
        ScreenErrorView.Model(
            title: error.localizedDescription,
            buttonTitle: "Попробовать снова"
        )
    }

    // MARK: - Private Methods

    private func makeNoteRowModel(from note: NotePayload) -> NoteModel {
        NoteModel(
            id: note.id,
            title: note.title,
            description: note.description,
            url: note.link,
            isFavorite: note.isFavorite
        )
    }

}
