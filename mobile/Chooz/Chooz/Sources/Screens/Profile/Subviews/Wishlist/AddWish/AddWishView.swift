import SwiftUI

struct AddWishView: View {
    
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
                
                AddWishPhotoSectionView(viewModel: viewModel)
                
                addLinkView
                
                AddWishPriceView(viewModel: viewModel)
                
                createButtonView
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
    
    private var createButtonView: some View {
        Button(
            action: {
                viewModel.createWish()
                dismiss()
            },
            label: {
                Text("Создать событие")
                    .font(.velaSans(size: 16.0, weight: .bold))
                    .foregroundStyle(viewModel.isCreateEnabled ? Colors.Common.white : Colors.Neutral.grey400)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
        .background(viewModel.isCreateEnabled ? Colors.Blue.blue500 : Colors.Neutral.grey200)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .disabled(!viewModel.isCreateEnabled)
    }
}
