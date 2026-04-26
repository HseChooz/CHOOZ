import Foundation

@MainActor
struct NoteFormViewModelBuilder {

    // MARK: - Internal Methods

    static func makeViewModel(
        with formType: NoteFormType,
        notePerformer: any NoteActionPerformer,
        toastManager: ToastManager,
        analytics: NoteFormAnalytics? = nil
    ) -> NoteFormViewModelImpl {
        switch formType {
        case .create:
            return NoteFormViewModelImpl(
                formType: formType,
                formModel: NoteFormModel(),
                notePerformer: notePerformer,
                toastManager: toastManager,
                analytics: analytics
            )
        case .edit(let model):
            return NoteFormViewModelImpl(
                formType: formType,
                formModel: model,
                notePerformer: notePerformer,
                toastManager: toastManager,
                analytics: analytics
            )
        }
    }

}
