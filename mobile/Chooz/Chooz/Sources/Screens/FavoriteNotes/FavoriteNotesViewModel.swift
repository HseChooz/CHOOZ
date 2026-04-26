import SwiftUI
import Foundation

@MainActor
protocol FavoriteNotesViewModel:
    AnyObject,
    FavoriteNotesLoadedViewEventsHandler
{
    var viewState: FavoriteNotesViewState { get }

    func requestFavoriteNotes()
    func retryFavoriteNotesRequest()
}

@MainActor
@Observable
final class FavoriteNotesViewModelImpl: FavoriteNotesViewModel {

    // MARK: - Internal Properties

    private(set) var viewState: FavoriteNotesViewState = .loading

    // MARK: - Init

    init(
        interactor: NotesInteractor,
        router: FavoriteNotesRouter,
        viewStateBuilder: NotesViewStateBuilder,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter,
        analytics: FavoriteNotesAnalytics? = nil
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

    func requestFavoriteNotes() {
        trackScreenViewedIfNeeded()
        
        guard !hasRequestedFavoriteNotes else {
            return
        }

        hasRequestedFavoriteNotes = true
        forceRequestFavoriteNotes()
    }

    func retryFavoriteNotesRequest() {
        viewState = .loading
        forceRequestFavoriteNotes()
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

    func refreshFavoriteNotes() {
        viewState = .loading
        forceRequestFavoriteNotes()
    }

    // MARK: - Private Properties

    private let interactor: NotesInteractor
    private let router: FavoriteNotesRouter
    private let viewStateBuilder: NotesViewStateBuilder
    private let notePerformer: any NoteActionPerformer
    private let noteReporter: any NoteActionReporter
    private let noteObserver: NoteObserver
    private let analytics: FavoriteNotesAnalytics?

    private var hasRequestedFavoriteNotes = false
    private var hasTrackedScreenView = false
    private var requestFavoriteNotesTask: Task<Void, Never>?
    private var noteActionTask: Task<Void, Never>?
    private var sourcePayload: [NotePayload] = []
    private var optimisticallyRemovedNotes: [String: RemovedFavoriteNote] = [:]

    // MARK: - Private Methods

    private func forceRequestFavoriteNotes() {
        requestFavoriteNotesTask?.cancel()

        requestFavoriteNotesTask = Task {
            do {
                let notes = try await interactor.requestNotes()
                sourcePayload = notes
                optimisticallyRemovedNotes.removeAll()
                renderFavoriteNotes()
            } catch let error as FavoriteNotesErrorType {
                print(error.localizedDescription)
                viewState = .error(viewStateBuilder.buildFavoriteNotesErrorViewState(from: error))
            } catch {
                print(error)
                viewState = .error(viewStateBuilder.buildFavoriteNotesErrorViewState(from: .unknown))
            }
        }
    }

    private func performNoteAction(_ action: NoteAction, target: NoteActionTarget) {
        noteActionTask?.cancel()

        noteActionTask = Task(priority: .userInitiated) {
            let _ = try? await notePerformer.perform(action: action, for: target)
        }
    }

    private func handleWillPerform(action: NoteAction, target: NoteActionTarget) {
        guard case .setFavorite(false) = action,
              case .note(let noteId) = target,
              let index = sourcePayload.firstIndex(where: { $0.id == noteId })
        else {
            return
        }

        optimisticallyRemovedNotes[noteId] = RemovedFavoriteNote(
            note: sourcePayload[index],
            index: index
        )
        sourcePayload.remove(at: index)
        renderFavoriteNotes(animated: true)
    }

    private func handleDidPerform(
        action: NoteAction,
        target: NoteActionTarget,
        result: NoteActionResult
    ) {
        switch (action, target, result) {
        case (.create, .create, .note(let note)):
            if note.isFavorite {
                upsertFavoriteNoteAtTop(note)
            }
        case (.update, .note(_), .note(let note)):
            if note.isFavorite {
                upsertFavoriteNote(note)
            } else {
                removeFavoriteNote(id: note.id)
            }
        case (.setFavorite, .note(let noteId), .note(let note)):
            optimisticallyRemovedNotes[noteId] = nil
            if note.isFavorite {
                upsertFavoriteNoteAtTop(note)
            } else {
                removeFavoriteNote(id: noteId)
            }
        case (.delete, .note(let noteId), .deleted):
            optimisticallyRemovedNotes[noteId] = nil
            removeFavoriteNote(id: noteId)
        case (.create, _, _),
             (.update, _, _),
             (.setFavorite, _, _),
             (.delete, _, _):
            break
        }
    }

    private func handleFailPerform(action: NoteAction, target: NoteActionTarget) {
        guard case .setFavorite(false) = action,
              case .note(let noteId) = target,
              let removedNote = optimisticallyRemovedNotes.removeValue(forKey: noteId)
        else {
            return
        }

        let index = min(removedNote.index, sourcePayload.count)
        sourcePayload.insert(removedNote.note, at: index)
        renderFavoriteNotes(animated: true)
    }

    private func upsertFavoriteNoteAtTop(_ note: NotePayload) {
        sourcePayload.removeAll { $0.id == note.id }
        sourcePayload.insert(note, at: 0)
        renderFavoriteNotes(animated: true)
    }

    private func upsertFavoriteNote(_ note: NotePayload) {
        if let index = sourcePayload.firstIndex(where: { $0.id == note.id }) {
            sourcePayload[index] = note
        } else {
            sourcePayload.insert(note, at: 0)
        }
        renderFavoriteNotes(animated: true)
    }

    private func removeFavoriteNote(id: String) {
        sourcePayload.removeAll { $0.id == id }
        renderFavoriteNotes(animated: true)
    }

    private func renderFavoriteNotes(animated: Bool = false) {
        let newState: FavoriteNotesViewState = sourcePayload.isEmpty
            ? .idle
            : .loaded(viewStateBuilder.buildFavoriteNotesLoadedContentViewState(from: sourcePayload))

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

// MARK: - Private Types

private struct RemovedFavoriteNote {
    let note: NotePayload
    let index: Int
}

// MARK: - NoteObserver

extension FavoriteNotesViewModelImpl {

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
