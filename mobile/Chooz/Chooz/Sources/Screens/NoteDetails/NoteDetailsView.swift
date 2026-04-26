import SwiftUI

struct NoteDetailsView<ViewModel: NoteDetailsViewModel>: View {

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24.0) {
            toolbarView
                .padding(.horizontal, 16.0)

            VStack(alignment: .leading, spacing: 74.0) {
                VStack(alignment: .leading, spacing: 16.0) {
                    Text(viewModel.noteModel.title)
                        .font(.velaSans(size: 20.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey900)

                    FadeScrollView(maxHeight: Layout.descriptionMaxHeight) {
                        Text(viewModel.noteModel.description)
                            .font(.velaSans(size: 16.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey600)
                    }
                }
                .padding(.horizontal, 16.0)

                VStack(alignment: .leading, spacing: 50.0) {
                    if let url = viewModel.noteModel.url {
                        Button(
                            action: {
                                viewModel.openNoteLink(url, openURL: openURL)
                            },
                            label: {
                                VStack(alignment: .leading, spacing: 8.0) {
                                    Text("Ссылка")
                                        .font(.velaSans(size: 16.0, weight: .bold))
                                        .foregroundStyle(Colors.Neutral.grey500)

                                    HorizontalLine()
                                        .stroke(lineWidth: 1.0)
                                        .foregroundStyle(Colors.Neutral.grey200)
                                        .frame(height: 1)
                                }
                            }
                        )
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 16.0)
                    }

                    actionButtonsView
                }
            }
        }
        .confirmationDialog(
            isPresented: Binding(
                get: { viewModel.isDeleteConfirmationPresented },
                set: { viewModel.isDeleteConfirmationPresented = $0 }
            ),
            title: "Вы уверены, что хотите удалить заметку?",
            primaryAction: ConfirmationDialogAction(title: "Оставить") {},
            destructiveAction: ConfirmationDialogAction(title: "Удалить") {
                viewModel.deleteNote()
            }
        )
        .onChange(of: viewModel.shouldDismissDetails) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
                viewModel.acknowledgeDetailsDismiss()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .padding(.top, 24.0)
        .padding(.bottom, Layout.bottomPadding.value(for: interfaceLayout))
    }

    // MARK: - Private Types

    private enum Layout {

        static var bottomPadding: InterfaceLayoutValue<CGFloat> {
            InterfaceLayoutValue(
                large: 32.0,
                compact: .zero
            )
        }
        static var descriptionLineHeight: CGFloat { 22.0 }
        static var maxLines: Int { 8 }
        static var descriptionMaxHeight: CGFloat { descriptionLineHeight * CGFloat(maxLines) }

    }

    // MARK: - Private Properties

    private let viewModel: ViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
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

    private var actionButtonsView: some View {
        HStack(spacing: .zero) {
            Button(
                action: {
                    viewModel.isDeleteConfirmationPresented = true
                },
                label: {
                    Images.Icons.trash
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18.0, height: 18.0)
                }
            )
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            Button(
                action: {
                    viewModel.toggleFavorite()
                },
                label: {
                    bookmarkImage
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18.0, height: 18.0)
                        .foregroundStyle(Colors.Neutral.grey99)
                }
            )
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            Button(
                action: {
                    viewModel.openEditNoteForm()
                },
                label: {
                    Images.Icons.edit
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18.0, height: 18.0)
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 40.0)
    }

    @ViewBuilder
    private var bookmarkImage: Image {
        viewModel.noteModel.isFavorite ? Images.Icons.bookmarked : Images.Icons.bookmark
    }

}
