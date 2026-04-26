import SwiftUI
import Observation

@MainActor
protocol NoteDetailsViewModel:
    AnyObject
{
    var noteModel: NoteModel { get }
    var isDeleteConfirmationPresented: Bool { get set }
    var shouldDismissDetails: Bool { get }

    func onAppear()
    func openEditNoteForm()
    func openNoteLink(_ url: URL, openURL: OpenURLAction)
    func deleteNote()
    func toggleFavorite()
    func acknowledgeDetailsDismiss()
}

@MainActor
@Observable
final class NoteDetailsViewModelImpl: NoteDetailsViewModel {

    // MARK: - Internal Properties

    private(set) var noteModel: NoteModel
    var isDeleteConfirmationPresented: Bool = false
    private(set) var shouldDismissDetails: Bool = false

    // MARK: - Internal Methods
    
    func onAppear() {
        trackScreenViewedIfNeeded()
    }

    func openEditNoteForm() {
        analytics?.trackNoteFormOpened(mode: "edit")
        router.routeTo(
            destination: .noteForm(
                formType: .edit(NoteFormModel(
                    id: noteModel.id,
                    title: noteModel.title,
                    description: noteModel.description,
                    link: noteModel.url?.absoluteString ?? ""
                )),
                notePerformer: notePerformer,
                noteReporter: noteReporter
            )
        )
    }
    
    func openNoteLink(_ url: URL, openURL: OpenURLAction) {
        analytics?.trackNoteLinkOpened(noteId: noteModel.id)
        openURL(url)
    }

    func deleteNote() {
        guard !isDeleteLoading else {
            return
        }

        deleteNoteTask?.cancel()
        deleteNoteTask = Task {
            isDeleteLoading = true

            do {
                _ = try await notePerformer.perform(action: .delete, for: .note(noteModel.id))
                shouldDismissDetails = true
            } catch {
                if !Task.isCancelled {
                    isDeleteLoading = false
                    toastManager.showError("Не удалось удалить заметку")
                }
            }
        }
    }

    func toggleFavorite() {
        let previousIsFavorite = noteModel.isFavorite
        noteModel.isFavorite.toggle()
        let targetIsFavorite = noteModel.isFavorite

        favoriteNoteTask?.cancel()
        favoriteNoteTask = Task {
            do {
                let result = try await notePerformer.perform(
                    action: .setFavorite(targetIsFavorite),
                    for: .note(noteModel.id)
                )
                if case .note(let note) = result {
                    noteModel = makeNoteModel(from: note)
                }
            } catch {
                if !Task.isCancelled {
                    noteModel.isFavorite = previousIsFavorite
                }
            }
        }
    }

    func acknowledgeDetailsDismiss() {
        shouldDismissDetails = false
        isDeleteLoading = false
    }

    // MARK: - Init

    init(
        noteModel: NoteModel,
        router: NoteDetailsRouter,
        notePerformer: any NoteActionPerformer,
        noteReporter: any NoteActionReporter,
        toastManager: ToastManager,
        analytics: NoteDetailsAnalytics? = nil
    ) {
        self.noteModel = noteModel
        self.router = router
        self.notePerformer = notePerformer
        self.noteReporter = noteReporter
        self.toastManager = toastManager
        self.analytics = analytics
    }

    // MARK: - Private Properties

    private let router: NoteDetailsRouter
    private let notePerformer: any NoteActionPerformer
    private let noteReporter: any NoteActionReporter
    private let toastManager: ToastManager
    private let analytics: NoteDetailsAnalytics?
    private var isDeleteLoading: Bool = false
    private var hasTrackedScreenView: Bool = false
    private var deleteNoteTask: Task<Void, Never>?
    private var favoriteNoteTask: Task<Void, Never>?

    // MARK: - Private Methods

    private func makeNoteModel(from note: NotePayload) -> NoteModel {
        NoteModel(
            id: note.id,
            title: note.title,
            description: note.description,
            url: note.link,
            isFavorite: note.isFavorite
        )
    }
    
    private func trackScreenViewedIfNeeded() {
        guard !hasTrackedScreenView else { return }
        
        hasTrackedScreenView = true
        analytics?.trackScreenViewed()
    }

}
