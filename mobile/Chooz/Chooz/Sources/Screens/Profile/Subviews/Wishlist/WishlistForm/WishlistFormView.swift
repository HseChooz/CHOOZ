import SwiftUI

struct WishlistFormView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            toolbarView
            
            VStack(spacing: 16.0) {
                titleRowView
                
                descriptionView
                
                WishlistFormPhotoSectionView(viewModel: viewModel)
                
                AddLinkView(linkString: $viewModel.link)
            }
            
            WishlistFormPriceView(viewModel: viewModel)
                
            saveButtonView
        }
        .padding(.horizontal, 16.0)
        .padding(.top, 24.0)
        .padding(Layout.bottomPadding.value(for: interfaceLayout))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Colors.Common.white)
    }
    
    // MARK: - Private Types
    
    private enum Layout {
        static let bottomPadding: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 32.0,
            compact: .zero
        )
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    private var isEditMode: Bool {
        viewModel.wishFormMode == .edit
    }
    
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
        .frame(maxWidth: .infinity)
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
    
    private var saveButtonView: some View {
        MainActionButton(
            title: isEditMode ? "Сохранить" : "Создать событие",
            backgroundColor: viewModel.isSaveEnabled ? Colors.Blue.blue500 : Colors.Neutral.grey200,
            foregroundColor: viewModel.isSaveEnabled ? Colors.Common.white : Colors.Neutral.grey400,
            action: {
                if viewModel.saveWish() {
                    dismiss()
                }
            }
        )
        .disabled(!viewModel.isSaveEnabled)
    }
}
