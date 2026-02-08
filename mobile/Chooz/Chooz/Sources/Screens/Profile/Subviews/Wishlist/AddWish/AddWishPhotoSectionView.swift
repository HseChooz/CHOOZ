import SwiftUI
import PhotosUI

struct AddWishPhotoSectionView: View {
    
    // MARK: - Init
    
    init(viewModel: WishlistViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        PhotosPicker(
            selection: $viewModel.imageSelection,
            matching: .images
        ) {
            contentView
                .frame(maxWidth: .infinity)
                .frame(height: 92.0)
                .overlay {
                    RoundedRectangle(cornerRadius: 20.0)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.0, dash: [6.0]))
                        .foregroundStyle(Colors.Neutral.grey400)
                }
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable private var viewModel: WishlistViewModel
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        if let selectedImage = viewModel.selectedImage {
            selectedImage
                .resizable()
                .scaledToFit()
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 4.0) {
            Images.Icons.camera
                .foregroundStyle(Colors.Neutral.grey400)
            
            Text("Добавить фото")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey400)
        }
    }
}
