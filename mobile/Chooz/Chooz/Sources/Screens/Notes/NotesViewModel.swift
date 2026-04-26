import SwiftUI
import Foundation

@MainActor
protocol NotesViewModel:
    AnyObject,
    NotesIdleViewEventsHandler,
    NotesLoadedViewEventsHandler
{
    var viewState: NotesViewState { get }

    func requestNotes()
    func retryNotesRequest()
}

@MainActor
@Observable
final class NotesViewModelImpl: NotesViewModel {

    // MARK: - Internal Properties

    private(set) var viewState: NotesViewState = .loading

    // MARK: - Init

    init(
        interactor: NotesInteractor,
        router: NotesRouter,
        viewStateBuilder: NotesViewStateBuilder,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter,
        analytics: NotesAnalytics? = nil
    ) {
        self.interactor = interactor
        self.router = router
        self.viewStateBuilder = viewStateBuilder
        self.notePerformer = notePerformer
        self.noteReporter = noteReporter
        self.analytics = analytics

        let observer = NoteObserver()
        self.noteObserver = observer

        observer.onWillPerform = { [weak self] action, target in
            self?.handleWillPerform(action: action, target: target)
        }
        observer.onDidPerform = { [weak self] action, target, result in
            self?.handleDidPerform(action: action, target: target, result: result)
        }
        observer.onFailPerform = { [weak self] action, target in
            self?.handleFailPerform(action: action, target: target)
        }

        noteReporter.addObserver(observer)
    }

    // MARK: - Internal Methods

    func requestNotes() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedNotes else {
            return
        }

        hasRequestedNotes = true
        forceRequestNotes()
    }

    func retryNotesRequest() {
        viewState = .loading
        forceRequestNotes()
    }

    func createNote() {
        analytics?.trackNoteFormOpened(mode: "create")
        router.routeTo(destination: .noteForm(
            formType: .create,
            notePerformer: notePerformer,
            noteReporter: noteReporter
        ))
    }

    func openNoteDetails(noteModel: NoteModel) {
        analytics?.trackNoteDetailsOpened(noteId: noteModel.id)
        router.routeTo(destination: .noteDetails(noteModel: noteModel))
    }

    func setFavorite(noteId: String, isFavorite: Bool) {
        performNoteAction(.setFavorite(isFavorite), target: .note(noteId))
    }

    func refreshNotes() {
        viewState = .loading
        forceRequestNotes()
    }

    // MARK: - Private Properties

    private let interactor: NotesInteractor
    private let router: NotesRouter
    private let viewStateBuilder: NotesViewStateBuilder
    private let notePerformer: any NoteActionPerformer
    private let noteReporter: any NoteActionReporter
    private let noteObserver: NoteObserver
    private let analytics: NotesAnalytics?

    private var hasRequestedNotes = false
    private var hasTrackedScreenView = false
    private var requestNotesTask: Task<Void, Never>?
    private var noteActionTask: Task<Void, Never>?
    private var sourcePayload: [NotePayload] = []

    // MARK: - Private Methods

    private func forceRequestNotes() {
        requestNotesTask?.cancel()

        requestNotesTask = Task {
            do {
                let notes = try await interactor.requestNotes()
                sourcePayload = notes
                renderNotes()
            } catch let error as NotesErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildNotesErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildNotesErrorViewState(from: .unknown))
            }
        }
    }

    private func performNoteAction(_ action: NoteAction, target: NoteActionTarget) {
        noteActionTask?.cancel()

        noteActionTask = Task(priority: .userInitiated) {
            try? await notePerformer.perform(action: action, for: target)
        }
    }

    private func handleWillPerform(action: NoteAction, target: NoteActionTarget) {
        guard case .setFavorite(let isFavorite) = action,
              case .note(let noteId) = target
        else {
            return
        }

        updateNoteFavorite(noteId: noteId, isFavorite: isFavorite)
    }

    private func handleDidPerform(
        action: NoteAction,
        target: NoteActionTarget,
        result: NoteActionResult
    ) {
        switch (action, target, result) {
        case (.create, .create, .note(let note)):
            upsertNoteAtTop(note)
        case (.update, .note(_), .note(let note)),
             (.setFavorite, .note(_), .note(let note)):
            replaceNoteIfExists(note)
        case (.delete, .note(let noteId), .deleted):
            removeNote(id: noteId)
        case (.create, _, _),
             (.update, _, _),
             (.setFavorite, _, _),
             (.delete, _, _):
            break
        }
    }

    private func handleFailPerform(action: NoteAction, target: NoteActionTarget) {
        guard case .setFavorite(let isFavorite) = action,
              case .note(let noteId) = target
        else {
            return
        }

        updateNoteFavorite(noteId: noteId, isFavorite: !isFavorite)
    }

    private func updateNoteFavorite(noteId: String, isFavorite: Bool) {
        guard let index = sourcePayload.firstIndex(where: { $0.id == noteId }) else {
            return
        }

        sourcePayload[index].isFavorite = isFavorite
        renderNotes(animated: true)
    }

    private func replaceNoteIfExists(_ note: NotePayload) {
        guard let index = sourcePayload.firstIndex(where: { $0.id == note.id }) else {
            return
        }

        sourcePayload[index] = note
        renderNotes(animated: true)
    }

    private func upsertNoteAtTop(_ note: NotePayload) {
        sourcePayload.removeAll { $0.id == note.id }
        sourcePayload.insert(note, at: 0)
        renderNotes(animated: true)
    }

    private func removeNote(id: String) {
        sourcePayload.removeAll { $0.id == id }
        renderNotes(animated: true)
    }

    private func renderNotes(animated: Bool = false) {
        let newState: NotesViewState = sourcePayload.isEmpty
            ? .idle
            : .loaded(viewStateBuilder.buildNotesLoadedContentViewState(from: sourcePayload))

        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewState = newState
            }
        } else {
            viewState = newState
        }
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }

}

// MARK: - NoteObserver

extension NotesViewModelImpl {

    fileprivate final class NoteObserver: ActionPerformerObserver, @unchecked Sendable {

        // MARK: - Internal Properties

        var onWillPerform: (@MainActor (NoteAction, NoteActionTarget) -> Void)?
        var onDidPerform: (@MainActor (NoteAction, NoteActionTarget, NoteActionResult) -> Void)?
        var onFailPerform: (@MainActor (NoteAction, NoteActionTarget) -> Void)?

        // MARK: - ActionPerformerObserver

        func willPerform(
            action: NoteAction,
            for target: NoteActionTarget,
            in performer: any ActionPerformer<NoteAction, NoteActionTarget, NoteActionResult>
        ) {
            Task { @MainActor [onWillPerform] in
                onWillPerform?(action, target)
            }
        }

        func didPerform(
            action: NoteAction,
            for target: NoteActionTarget,
            with result: NoteActionResult,
            in performer: any ActionPerformer<NoteAction, NoteActionTarget, NoteActionResult>
        ) {
            Task { @MainActor [onDidPerform] in
                onDidPerform?(action, target, result)
            }
        }

        func failPerform(
            action: NoteAction,
            for target: NoteActionTarget,
            with error: Error,
            in performer: any ActionPerformer<NoteAction, NoteActionTarget, NoteActionResult>
        ) {
            Task { @MainActor [onFailPerform] in
                onFailPerform?(action, target)
            }
        }

    }

}
