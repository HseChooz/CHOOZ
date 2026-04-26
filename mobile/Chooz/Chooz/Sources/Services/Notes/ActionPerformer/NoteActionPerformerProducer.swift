import Foundation

@MainActor
protocol NoteActionPerformerProducerDeps {
    var notesService: NotesService { get }
}

@MainActor
struct NoteActionPerformerProducerDepsImpl: NoteActionPerformerProducerDeps {
    let notesService: NotesService
}

@MainActor
final class NoteActionPerformerProducer: Sendable {

    // MARK: - Internal Properties

    var reporter: some NoteActionReporter {
        rootObservableActionPerformer
    }

    // MARK: - Init

    init(deps: NoteActionPerformerProducerDeps) {
        self.deps = deps
    }

    // MARK: - Internal Methods

    func makePerformer() -> some NoteActionPerformer {
        rootObservableActionPerformer
    }

    // MARK: - Private Properties

    private let deps: NoteActionPerformerProducerDeps

    private lazy var rootObservableActionPerformer = NoteBaseActionPerformer(
        service: deps.notesService
    ).coordinated()

}

private final class NoteBaseActionPerformer: ActionPerformer {

    // MARK: - Init

    init(service: NotesService) {
        self.service = service
    }

    // MARK: - Internal Methods

    func perform(action: NoteAction, for target: NoteActionTarget) async throws -> NoteActionResult {
        try Task.checkCancellation()

        switch (action, target) {
        case (.create(let model), .create):
            let note = try await service.createNote(model)
            return .note(note)
        case (.update(let model), .note(let noteId)):
            let note = try await service.updateNote(
                id: noteId,
                title: model.title,
                description: model.description,
                link: model.link,
                isFavorite: nil
            )
            return .note(note)
        case (.setFavorite(let isFavorite), .note(let noteId)):
            let note = try await service.updateNoteFavorite(id: noteId, isFavorite: isFavorite)
            return .note(note)
        case (.delete, .note(let noteId)):
            try await service.deleteNote(id: noteId)
            return .deleted
        case (.create, .note(_)),
             (.update, .create),
             (.setFavorite, .create),
             (.delete, .create):
            throw CancellationError()
        }
    }

    // MARK: - Private Properties

    private let service: NotesService

}
