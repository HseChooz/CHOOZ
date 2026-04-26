import SwiftUI
import Observation

@MainActor
protocol NotesTabViewModel:
    AnyObject,
    NotesTabToolbarContentEventsHandler
{
    var selectedSegment: NotesTabSegment { get set }
    
    func onAppear()
}

@MainActor
@Observable
final class NotesTabViewModelImpl: NotesTabViewModel {

    // MARK: - Internal Properties

    var selectedSegment: NotesTabSegment = .allNotes

    // MARK: - Init

    init(
        router: NotesTabRouter,
        noteReporter: any NoteActionReporter,
        toastManager: ToastManager,
        analytics: NotesTabAnalytics? = nil
    ) {
        self.router = router
        self.noteReporter = noteReporter
        self.toastManager = toastManager
        self.analytics = analytics

        let observer = NoteObserver()
        self.noteObserver = observer

        observer.onDidPerform = { [weak self] action, target, result in
            self?.handleDidPerform(action: action, target: target, result: result)
        }

        noteReporter.addObserver(observer)
    }

    // MARK: - Internal Methods
    
    func onAppear() {
        trackScreenViewedIfNeeded()
    }

    func openProfile() {
        analytics?.trackProfileOpened()
        router.routeTo(destination: .profile)
    }

    // MARK: - Private Properties

    private let router: NotesTabRouter
    private let noteReporter: any NoteActionReporter
    private let toastManager: ToastManager
    private let noteObserver: NoteObserver
    private let analytics: NotesTabAnalytics?
    private var hasTrackedScreenView = false

    // MARK: - Private Methods

    private func handleDidPerform(
        action: NoteAction,
        target: NoteActionTarget,
        result: NoteActionResult
    ) {
        switch (action, target, result) {
        case (.create, .create, .note(let note)):
            analytics?.trackNoteCreated(title: note.title)
            toastManager.showSuccessBlue("Добавлена новая заметка")
        case (.update, .note(let noteId), .note):
            analytics?.trackNoteEdited(noteId: noteId)
        case (.setFavorite(let isFavorite), .note(let noteId), .note):
            analytics?.trackNoteFavoriteToggled(noteId: noteId, enabled: isFavorite)
        case (.delete, .note(let noteId), .deleted):
            analytics?.trackNoteDeleted(noteId: noteId)
        case (.create, _, _),
             (.update, _, _),
             (.setFavorite, _, _),
             (.delete, _, _):
            break
        }
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }

}

// MARK: - NoteObserver

extension NotesTabViewModelImpl {

    fileprivate final class NoteObserver: ActionPerformerObserver, @unchecked Sendable {

        // MARK: - Internal Properties

        var onDidPerform: (@MainActor (NoteAction, NoteActionTarget, NoteActionResult) -> Void)?

        // MARK: - ActionPerformerObserver

        func willPerform(
            action: NoteAction,
            for target: NoteActionTarget,
            in performer: any ActionPerformer<NoteAction, NoteActionTarget, NoteActionResult>
        ) {}

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
        ) {}

    }

}
