import SwiftUI
import Observation

@MainActor
protocol NoteFormViewModel:
    AnyObject
{
    var formType: NoteFormType { get }
    var formModel: NoteFormModel { get set }
    var isButtonEnabled: Bool { get }
    var shouldDismissForm: Bool { get }

    func createNote()
    func updateNote()
    func acknowledgeFormDismiss()
    func formDidDisappear()
}

@MainActor
@Observable
final class NoteFormViewModelImpl: NoteFormViewModel {

    // MARK: - Internal Properties

    let formType: NoteFormType

    var formModel: NoteFormModel
    private(set) var shouldDismissForm: Bool = false
    var isButtonEnabled: Bool {
        !formModel.title.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading
    }

    // MARK: - Init

    init(
        formType: NoteFormType,
        formModel: NoteFormModel,
        notePerformer: any NoteActionPerformer,
        toastManager: ToastManager
    ) {
        self.formType = formType
        self.formModel = formModel
        self.notePerformer = notePerformer
        self.toastManager = toastManager
    }

    // MARK: - Internal Methods

    func createNote() {
        guard !isLoading else {
            return
        }
        guard validateForm() else {
            return
        }

        noteActionTask?.cancel()
        noteActionTask = Task {
            isLoading = true

            do {
                _ = try await notePerformer.perform(action: .create(formModel), for: .create)
                shouldDismissForm = true
            } catch {
                if !Task.isCancelled {
                    isLoading = false
                }
            }
        }
    }

    func updateNote() {
        guard !isLoading else {
            return
        }
        guard validateForm() else {
            return
        }
        guard case .edit = formType, let noteId = formModel.id else {
            toastManager.showError("Не удалось сохранить заметку")
            return
        }

        noteActionTask?.cancel()
        noteActionTask = Task {
            isLoading = true

            do {
                _ = try await notePerformer.perform(action: .update(formModel), for: .note(noteId))
                shouldDismissForm = true
            } catch {
                if !Task.isCancelled {
                    isLoading = false
                    toastManager.showError("Не удалось сохранить заметку")
                }
            }
        }
    }

    func acknowledgeFormDismiss() {
        shouldDismissForm = false
        isLoading = false
    }

    func formDidDisappear() {
        noteActionTask?.cancel()
        noteActionTask = nil
        isLoading = false
    }

    // MARK: - Private Properties

    private let notePerformer: any NoteActionPerformer
    private let toastManager: ToastManager
    private var isLoading: Bool = false
    private var noteActionTask: Task<Void, Never>?

    // MARK: - Private Methods

    private func validateForm() -> Bool {
        let trimmedLink = formModel.link.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedLink.isEmpty else {
            return true
        }

        guard let url = URL(string: trimmedLink),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host?.isEmpty == false
        else {
            present(error: .invalidLink)
            return false
        }

        return true
    }

    private func present(error: NoteFormError) {
        toastManager.showError(error.title, subtitle: error.subtitle)
    }

}
