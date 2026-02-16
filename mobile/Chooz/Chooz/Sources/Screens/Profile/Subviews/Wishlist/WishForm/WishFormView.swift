import SwiftUI

struct WishFormView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16.0) {
                titleRowView
                
                descriptionView
                
                WishFormPhotoSectionView(viewModel: viewModel)
                
                addLinkView
                
                WishFormPriceView(viewModel: viewModel)
                
                saveButtonView
            }
            .padding(.horizontal, 16.0)
            .padding(.top, 24.0)
            .padding(.bottom, 32.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background(Colors.Common.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContentView
            }
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private var isEditMode: Bool {
        viewModel.wishFormMode == .edit
    }
    
    // MARK: - Private Views
    
    @ToolbarContentBuilder
    private var toolbarContentView: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Images.Icons.crossLarge
                        .foregroundStyle(Colors.Neutral.grey5b)
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    private var titleRowView: some View {
        TextField(
            "",
            text: $viewModel.title,
            prompt:
                Text("Заголовок")
                .font(.velaSans(size: 20.0, weight: .bold))
                .foregroundStyle(Colors.Common.black)
        )
        .lineLimit(1)
        .font(.velaSans(size: 20.0, weight: .bold))
        .foregroundStyle(Colors.Common.black)
    }
    
    private var descriptionView: some View {
        TextField(
            "Добавить описание здесь...",
            text: $viewModel.description,
            axis: .vertical
        )
        .font(.velaSans(size: 16.0, weight: .bold))
        .foregroundStyle(Colors.Neutral.grey400)
        .lineLimit(3...6)
    }
    
    private var addLinkView: some View {
        TextField(
            "",
            text: $viewModel.link,
            prompt: Text("Добавить ссылку")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey400)
        )
        .font(.velaSans(size: 16.0, weight: .bold))
        .foregroundStyle(Colors.Neutral.grey800)
        .keyboardType(.URL)
        .textContentType(.URL)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .padding(.horizontal, 16.0)
        .frame(height: 64.0)
        .overlay {
            RoundedRectangle(cornerRadius: 20.0)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.0, dash: [6.0]))
                .foregroundStyle(Colors.Neutral.grey400)
        }
    }
    
    private var saveButtonView: some View {
        Button(
            action: {
                viewModel.saveWish()
                dismiss()
            },
            label: {
                Text(isEditMode ? "Сохранить" : "Создать событие")
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(viewModel.isSaveEnabled ? Colors.Common.white : Colors.Neutral.grey400)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
        .background(viewModel.isSaveEnabled ? Colors.Blue.blue500 : Colors.Neutral.grey200)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .disabled(!viewModel.isSaveEnabled)
    }
}
