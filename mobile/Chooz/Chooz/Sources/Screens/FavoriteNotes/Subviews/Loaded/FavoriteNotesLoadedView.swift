import SwiftUI

struct FavoriteNotesLoadedView: View {

    // MARK: - Internal Types

    struct Model: Hashable {
        let notes: [NoteModel]
    }

    // MARK: - Init

    init(model: Model, eventsHandler: FavoriteNotesLoadedViewEventsHandler) {
        self.model = model
        self.eventsHandler = eventsHandler
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8.0) {
                ForEach(model.notes, id: \.id) { note in
                    NoteRowView(
                        model: note,
                        mainAction: { eventsHandler.openNoteDetails(noteModel: note) },
                        bookmarkAction: {
                            eventsHandler.setFavorite(noteId: note.id, isFavorite: !note.isFavorite)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 17.0)
        .padding(.top, 26.0)
        .overlay(alignment: .bottom) {
            MainActionButton(
                title: "Создать заметку",
                backgroundColor: Colors.Neutral.grey800,
                foregroundColor: Colors.Common.white,
                action: eventsHandler.createNote
            )
            .padding(.horizontal, 24.0)
            .padding(.bottom, 16.0)
        }
        .refreshable {
            eventsHandler.refreshFavoriteNotes()
        }
    }

    // MARK: - Private Properties

    private let model: Model
    private let eventsHandler: FavoriteNotesLoadedViewEventsHandler

}
