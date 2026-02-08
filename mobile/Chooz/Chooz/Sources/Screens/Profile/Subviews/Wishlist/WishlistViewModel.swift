import Foundation
import SwiftUI
import Observation
import PhotosUI

@MainActor
@Observable
final class WishlistViewModel {
    
    // MARK: - Init
    
    init(wishlistService: WishlistService) {
        self.wishlistService = wishlistService
    }
    
    // MARK: - Internal Properties
    
    var wishlistState: WishlistState {
        let wishes = wishlistService.wishes
        return wishes.isEmpty ? .empty : .loaded(wishes)
    }
    
    var isAddWishSheetPresented: Bool = false
    
    var title: String = ""
    var description: String = ""
    var link: String = ""
    var price: String = ""
    var selectedCurrency: WishCurrency = .rub
    private(set) var selectedImage: Image?
    private(set) var selectedImageData: Data?
    
    var isCreateEnabled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !price.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var imageSelection: PhotosPickerItem? {
        didSet {
            loadImageData()
        }
    }
    
    // MARK: - Internal Methods
    
    func showAddWishSheet() {
        resetForm()
        isAddWishSheetPresented = true
    }
    
    func createWish() {
        Task {
            let trimmedLink = link.trimmingCharacters(in: .whitespaces)
            let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
            
            await wishlistService.addWish(
                title: title,
                image: selectedImage,
                description: description,
                link: trimmedLink.isEmpty ? nil : trimmedLink,
                price: trimmedPrice,
                currency: selectedCurrency,
            )
        }
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    
    // MARK: - Private Methods
    
    private func resetForm() {
        title = ""
        description = ""
        link = ""
        price = ""
        selectedCurrency = .rub
        selectedImage = nil
        selectedImageData = nil
        imageSelection = nil
    }
    
    private func loadImageData() {
        guard let item = imageSelection else {
            selectedImage = nil
            selectedImageData = nil
            return
        }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                selectedImageData = data
                
                if let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
