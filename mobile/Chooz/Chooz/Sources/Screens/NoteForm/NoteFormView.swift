import SwiftUI

struct NoteFormView<ViewModel: NoteFormViewModel>: View {

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24.0) {
            toolbarView

            VStack(spacing: 64.0) {
                VStack(alignment: .leading, spacing: 48.0) {
                    VStack(alignment: .leading, spacing: 16.0) {
                        titleFieldView

                        descriptionFieldView
                    }

                    AddLinkView(
                        linkString: Binding(
                            get: { viewModel.formModel.link },
                            set: { viewModel.formModel.link = $0 }
                        )
                    )
                }

                MainActionButton(
                    title: viewModel.formType == .create ? "Создать заметку" : "Сохранить заметку",
                    backgroundColor: viewModel.isButtonEnabled ? Colors.Blue.blue500 : Colors.Neutral.grey200,
                    foregroundColor: viewModel.isButtonEnabled ? Colors.Common.white : Colors.Neutral.grey400,
                    action: viewModel.formType == .create ? viewModel.createNote : viewModel.updateNote
                )
                .disabled(!viewModel.isButtonEnabled)
            }
        }
        .padding(.top, 24.0)
        .padding(.horizontal, 16.0)
        .padding(.bottom, Layout.bottomPadding.value(for: interfaceLayout))
        .onChange(of: viewModel.shouldDismissForm) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
                viewModel.acknowledgeFormDismiss()
            }
        }
        .onDisappear {
            viewModel.formDidDisappear()
        }
    }

    // MARK: - Private Types

    private enum Layout {

        static var bottomPadding: InterfaceLayoutValue<CGFloat> {
            InterfaceLayoutValue(
                large: 32.0,
                compact: .zero
            )
        }

    }

    // MARK: - Private Properties

    private let viewModel: ViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.interfaceLayout) private var interfaceLayout

    // MARK: - Private Views

    private var toolbarView: some View {
        HStack(spacing: .zero) {
            Spacer()

            Button(
                action: { dismiss() },
                label: {
                    Images.Icons.crossLarge
                        .foregroundStyle(Colors.Neutral.grey5b)
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(height: 24.0)
    }

    private var titleFieldView: some View {
        TextField(
            "Пустой заголовок",
            text: Binding(
                get: { viewModel.formModel.title },
                set: { viewModel.formModel.title = $0 }
            ),
        )
        .lineLimit(1)
        .font(.velaSans(size: 20.0, weight: .bold))
        .foregroundStyle(Colors.Common.black)
    }

    private var descriptionFieldView: some View {
        TextField(
            "Добавить описание здесь...",
            text: Binding(
                get: { viewModel.formModel.description },
                set: { viewModel.formModel.description = $0 }
            ),
            axis: .vertical
        )
        .font(.velaSans(size: 16.0, weight: .bold))
        .foregroundStyle(Colors.Neutral.grey600)
        .lineLimit(3...6)
    }

}
