import SwiftUI
import Observation

@MainActor
protocol NoteDetailsViewModel:
    AnyObject
{
    var noteModel: NoteModel { get }
    var isDeleteConfirmationPresented: Bool { get set }
    var shouldDismissDetails: Bool { get }

    func openEditNoteForm()
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

    func openEditNoteForm() {
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
        toastManager: ToastManager
    ) {
        self.noteModel = noteModel
        self.router = router
        self.notePerformer = notePerformer
        self.noteReporter = noteReporter
        self.toastManager = toastManager
    }

    // MARK: - Private Properties

    private let router: NoteDetailsRouter
    private let notePerformer: any NoteActionPerformer
    private let noteReporter: any NoteActionReporter
    private let toastManager: ToastManager
    private var isDeleteLoading: Bool = false
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

}
