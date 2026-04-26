import Foundation

@MainActor
protocol NotesInteractorDeps {
    var notesService: NotesService { get }
}

@MainActor
final class NotesInteractor {

    // MARK: - Init

    init(
        deps: NotesInteractorDeps,
        onlyFavorites: Bool
    ) {
        self.deps = deps
        self.onlyFavorites = onlyFavorites
    }

    // MARK: - Internal Methods

    func requestNotes() async throws -> [NotePayload] {
        try await deps.notesService.fetchNotes(onlyFavorites: onlyFavorites)
    }

    // MARK: - Private Properties

    private let deps: NotesInteractorDeps
    private let onlyFavorites: Bool

}
