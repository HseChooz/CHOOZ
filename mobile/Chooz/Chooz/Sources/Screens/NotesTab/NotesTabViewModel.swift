import SwiftUI
import Observation

@MainActor
protocol NotesTabViewModel:
    AnyObject,
    NotesTabToolbarContentEventsHandler
{
    var selectedSegment: NotesTabSegment { get set }
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
        toastManager: ToastManager
    ) {
        self.router = router
        self.noteReporter = noteReporter
        self.toastManager = toastManager

        let observer = NoteObserver()
        self.noteObserver = observer

        observer.onDidPerform = { [weak self] action, target in
            self?.handleDidPerform(action: action, target: target)
        }

        noteReporter.addObserver(observer)
    }

    // MARK: - Internal Methods

    func openProfile() {
        router.routeTo(destination: .profile)
    }

    // MARK: - Private Properties

    private let router: NotesTabRouter
    private let noteReporter: any NoteActionReporter
    private let toastManager: ToastManager
    private let noteObserver: NoteObserver

    // MARK: - Private Methods

    private func handleDidPerform(action: NoteAction, target: NoteActionTarget) {
        guard case .create = action,
              case .create = target
        else {
            return
        }

        toastManager.showSuccessBlue("Добавлена новая заметка")
    }

}

// MARK: - NoteObserver

extension NotesTabViewModelImpl {

    fileprivate final class NoteObserver: ActionPerformerObserver, @unchecked Sendable {

        // MARK: - Internal Properties

        var onDidPerform: (@MainActor (NoteAction, NoteActionTarget) -> Void)?

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
                onDidPerform?(action, target)
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
