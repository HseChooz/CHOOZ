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
    
    init(
        wishlistService: WishlistService,
        toastManager: ToastManager,
        analytics: WishlistAnalytics
    ) {
        self.wishlistService = wishlistService
        self.toastManager = toastManager
        self.analytics = analytics
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
    
    private(set) var isWishFormSaving: Bool = false
    private(set) var shouldDismissWishForm: Bool = false
    
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
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !isWishFormSaving
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
        resetWishFormSaveState()
        isWishFormSheetPresented = true
    }
    
    func showEditWishForm() {
        guard let item = selectedWishItem else { return }
        wishFormMode = .edit
        populateForm(from: item)
        resetWishFormSaveState()
        pendingFormPresentation = true
        isWishSheetPresented = false
    }
    
    func handleWishSheetDismiss() {
        if pendingFormPresentation {
            pendingFormPresentation = false
            isWishFormSheetPresented = true
        }
    }
    
    func saveWish() {
        guard validateForm() else { return }
        guard !isWishFormSaving else { return }
        
        saveWishTask?.cancel()
        saveWishTask = Task { @MainActor in
            isWishFormSaving = true
            defer {
                if !shouldDismissWishForm {
                    isWishFormSaving = false
                }
            }
            
            guard !Task.isCancelled else { return }
            
            let success: Bool
            switch wishFormMode {
            case .create:
                success = await createWish()
            case .edit:
                success = await updateWish()
            }
            
            guard !Task.isCancelled else { return }
            
            if success {
                shouldDismissWishForm = true
            }
        }
    }
    
    func acknowledgeWishFormDismiss() {
        shouldDismissWishForm = false
        isWishFormSaving = false
    }
    
    func wishFormDidDisappear() {
        saveWishTask?.cancel()
        saveWishTask = nil
        if isWishFormSaving {
            isWishFormSaving = false
        }
    }
    
    func showDeleteConfirmation() {
        isDeleteConfirmationPresented = true
    }
    
    func deleteWish() {
        guard let id = selectedWishItem?.id else { return }
        Task {
            let success = await wishlistService.deleteWish(id: id)
            if success {
                analytics.trackWishDeleted(itemId: id)
                isWishSheetPresented = false
                selectedWishItem = nil
            } else {
                presentMutationError(wishlistService.lastMutationError, fallbackTitle: "Не удалось удалить желание")
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let wishlistService: WishlistService
    private let toastManager: ToastManager
    private let analytics: WishlistAnalytics
    private var pendingFormPresentation: Bool = false
    private var saveWishTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func resetWishFormSaveState() {
        saveWishTask?.cancel()
        saveWishTask = nil
        isWishFormSaving = false
        shouldDismissWishForm = false
    }
    
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
        
        return true
    }
    
    private func presentMutationError(_ error: Error?, fallbackTitle: String) {
        guard let error else {
            toastManager.showError(fallbackTitle)
            return
        }
        let presentation = WishlistMutationErrorMessage.presentation(for: error)
        toastManager.showError(presentation.title, subtitle: presentation.subtitle)
    }
    
    private func createWish() async -> Bool {
        let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
        let imageData = prepareImageDataForUpload()
        
        guard let createdItem = await wishlistService.addWish(
            title: title,
            description: description,
            link: link.trimmingCharacters(in: .whitespaces),
            price: trimmedPrice.isEmpty ? nil : trimmedPrice,
            currency: selectedCurrency
        ) else {
            presentMutationError(wishlistService.lastMutationError, fallbackTitle: "Не удалось создать желание")
            return false
        }
        
        if let imageData {
            let updatedItem = await uploadImage(for: createdItem.id, data: imageData)
            if updatedItem == nil {
                selectedWishItem = createdItem
                return false
            }
            selectedWishItem = updatedItem
        } else {
            selectedWishItem = createdItem
        }
        
        analytics.trackWishAdded(title: self.title)
        toastManager.showSuccessBlue("Добавлена новая заметка")
        return true
    }
    
    private func updateWish() async -> Bool {
        guard let id = selectedWishItem?.id else { return false }
        let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
        let imageData = prepareImageDataForUpload()
        
        guard let updatedItem = await wishlistService.updateWish(
            id: id,
            title: title,
            description: description,
            link: link.trimmingCharacters(in: .whitespaces),
            price: trimmedPrice.isEmpty ? nil : trimmedPrice,
            currency: selectedCurrency
        ) else {
            presentMutationError(wishlistService.lastMutationError, fallbackTitle: "Не удалось сохранить желание")
            return false
        }
        
        analytics.trackWishEdited(itemId: id)
        
        if let imageData {
            let itemWithImage = await uploadImage(for: id, data: imageData)
            if itemWithImage == nil {
                selectedWishItem = updatedItem
                return false
            }
            selectedWishItem = itemWithImage
        } else {
            selectedWishItem = updatedItem
        }
        
        return true
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
            let presentation = WishlistMutationErrorMessage.presentation(for: error)
            toastManager.showError("Не удалось загрузить изображение", subtitle: presentation.subtitle ?? presentation.title)
            return nil
        }
    }
}
