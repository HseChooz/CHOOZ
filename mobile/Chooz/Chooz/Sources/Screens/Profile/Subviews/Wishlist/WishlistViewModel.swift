import Foundation
import SwiftUI
import Observation
import PhotosUI

@MainActor
@Observable
final class WishlistViewModel {
    
    // MARK: - Internal Types
    
    enum WishFormMode {
        case create
        case edit
    }
    
    // MARK: - Init
    
    init(wishlistService: WishlistService, toastManager: ToastManager) {
        self.wishlistService = wishlistService
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Properties
    
    var wishlistState: WishlistState {
        if wishlistService.isLoading {
            return .loading
        }
        if let _ = wishlistService.errorMessage {
            return .error
        }
        let wishes = wishlistService.wishes
        return wishes.isEmpty ? .empty : .loaded(wishes)
    }
    
    var isWishFormSheetPresented: Bool = false
    var isWishSheetPresented: Bool = false
    var isDeleteConfirmationPresented: Bool = false
    var selectedWishItem: WishlistItem?
    var wishFormMode: WishFormMode = .create
    
    var selectedItem: WishlistItem {
        guard let selectedWishItem else {
            return WishlistItem(id: "", title: "", description: nil, link: nil, price: nil, currency: nil, imageUrl: nil)
        }
        return selectedWishItem
    }
    
    var title: String = ""
    var description: String = ""
    var link: String = ""
    var price: String = ""
    var selectedCurrency: WishCurrency = .rub
    private(set) var selectedImage: Image?
    private(set) var selectedImageData: Data?
    private(set) var existingImageUrl: String?
    private(set) var isImageUploading: Bool = false
    
    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var imageSelection: PhotosPickerItem? {
        didSet {
            loadImageData()
        }
    }
    
    // MARK: - Internal Methods
    
    func fetchWishes() {
        Task {
            await wishlistService.fetchWishes()
        }
    }
    
    func refreshWishes() async {
        await wishlistService.fetchWishes()
    }
    
    func selectWishItem(_ item: WishlistItem) {
        selectedWishItem = item
        isWishSheetPresented = true
    }
    
    func showCreateWishForm() {
        wishFormMode = .create
        resetForm()
        isWishFormSheetPresented = true
    }
    
    func showEditWishForm() {
        guard let item = selectedWishItem else { return }
        wishFormMode = .edit
        populateForm(from: item)
        pendingFormPresentation = true
        isWishSheetPresented = false
    }
    
    func handleWishSheetDismiss() {
        if pendingFormPresentation {
            pendingFormPresentation = false
            isWishFormSheetPresented = true
        }
    }
    
    @discardableResult
    func saveWish() -> Bool {
        guard validateForm() else { return false }
        
        switch wishFormMode {
        case .create:
            createWish()
        case .edit:
            updateWish()
        }
        return true
    }
    
    func showDeleteConfirmation() {
        isDeleteConfirmationPresented = true
    }
    
    func deleteWish() {
        guard let id = selectedWishItem?.id else { return }
        Task {
            let success = await wishlistService.deleteWish(id: id)
            if success {
                isWishSheetPresented = false
                selectedWishItem = nil
            } else if let error = wishlistService.errorMessage {
                toastManager.showError(error)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    private let toastManager: ToastManager
    private var pendingFormPresentation: Bool = false
    
    // MARK: - Private Methods
    
    private func validateForm() -> Bool {
        let trimmedLink = link.trimmingCharacters(in: .whitespaces)
        if !trimmedLink.isEmpty {
            guard let url = URL(string: trimmedLink),
                  let scheme = url.scheme?.lowercased(),
                  scheme == "http" || scheme == "https" else {
                toastManager.showError("Некорректная ссылка")
                return false
            }
        }
        
        let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
        if !trimmedPrice.isEmpty {
            guard let value = Double(trimmedPrice), value >= 0 else {
                toastManager.showError("Некорректная цена")
                return false
            }
        }
        
        return true
    }
    
    private func createWish() {
        let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
        let imageData = prepareImageDataForUpload()
        Task {
            guard let createdItem = await wishlistService.addWish(
                title: title,
                description: description,
                link: link.trimmingCharacters(in: .whitespaces),
                price: trimmedPrice.isEmpty ? nil : trimmedPrice,
                currency: selectedCurrency
            ) else { return }
            
            if let imageData {
                let updatedItem = await uploadImage(for: createdItem.id, data: imageData)
                selectedWishItem = updatedItem ?? createdItem
            } else {
                selectedWishItem = createdItem
            }
            
            if wishlistService.errorMessage == nil {
                toastManager.showSuccessBlue("Добавлена новая заметка")
            }
        }
    }
    
    private func updateWish() {
        guard let id = selectedWishItem?.id else { return }
        let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
        let imageData = prepareImageDataForUpload()
        Task {
            guard let updatedItem = await wishlistService.updateWish(
                id: id,
                title: title,
                description: description,
                link: link.trimmingCharacters(in: .whitespaces),
                price: trimmedPrice.isEmpty ? nil : trimmedPrice,
                currency: selectedCurrency
            ) else { return }
            
            if let imageData {
                let itemWithImage = await uploadImage(for: id, data: imageData)
                selectedWishItem = itemWithImage ?? updatedItem
            } else {
                selectedWishItem = updatedItem
            }
        }
    }
    
    private func resetForm() {
        title = ""
        description = ""
        link = ""
        price = ""
        selectedCurrency = .rub
        selectedImage = nil
        selectedImageData = nil
        imageSelection = nil
        existingImageUrl = nil
    }
    
    private func populateForm(from item: WishlistItem) {
        title = item.title
        description = item.description ?? ""
        link = item.link ?? ""
        price = item.price ?? ""
        selectedCurrency = item.currency ?? .rub
        selectedImage = nil
        selectedImageData = nil
        imageSelection = nil
        existingImageUrl = item.imageUrl
    }
    
    private func loadImageData() {
        guard let item = imageSelection else {
            selectedImage = nil
            selectedImageData = nil
            return
        }
        
        existingImageUrl = nil
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                selectedImageData = data
                
                if let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    private func prepareImageDataForUpload() -> Data? {
        guard let selectedImageData,
              let uiImage = UIImage(data: selectedImageData) else {
            return nil
        }
        return uiImage.jpegData(compressionQuality: 0.8)
    }
    
    @discardableResult
    private func uploadImage(for itemId: String, data: Data) async -> WishlistItem? {
        isImageUploading = true
        defer { isImageUploading = false }
        
        let filename = "wish_\(itemId)_\(UUID().uuidString.prefix(8)).jpg"
        do {
            let updatedItem = try await wishlistService.uploadAndAttachImage(
                itemId: itemId,
                imageData: data,
                filename: filename,
                contentType: "image/jpeg"
            )
            return updatedItem
        } catch {
            print("[WishlistViewModel] Image upload failed: \(error)")
            toastManager.showError("Не удалось загрузить изображение")
            return nil
        }
    }
}
