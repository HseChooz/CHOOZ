import Foundation
import Apollo
import Observation

@MainActor
@Observable
final class WishlistService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Properties
    
    private(set) var wishes: [WishlistItem] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Internal Methods
    
    func fetchWishes() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<[WishlistItem], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.WishItemsQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    let items = graphQLResult.data?.wishItems.map { item in
                        WishlistItem(
                            id: item.id,
                            title: item.title,
                            description: item.description,
                            link: item.link,
                            price: item.price.map { String($0) },
                            currency: item.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: item.imageUrl
                        )
                    } ?? []
                    continuation.resume(returning: .success(items))
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        isLoading = false
        
        switch result {
        case .success(let items):
            wishes = items
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchWishItem(id: String) async throws -> WishlistItem {
        let result: Result<WishlistItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.WishItemQuery(id: id),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.wishItem {
                        let item = WishlistItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: data.link,
                            price: data.price.map { String($0) },
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: data.imageUrl
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить желание"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    func fetchUserWishItems(userId: String) async throws -> [WishlistItem] {
        let result: Result<[WishlistItem], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.UserWishItemsQuery(userId: userId),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    let items = graphQLResult.data?.userWishItems.map { item in
                        WishlistItem(
                            id: item.id,
                            title: item.title,
                            description: item.description,
                            link: item.link,
                            price: item.price.map { String($0) },
                            currency: item.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: item.imageUrl
                        )
                    } ?? []
                    continuation.resume(returning: .success(items))
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    @discardableResult
    func addWish(title: String, description: String, link: String, price: String?, currency: WishCurrency) async -> WishlistItem? {
        errorMessage = nil
        
        let result: Result<WishlistItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.CreateWishItemMutation(
                    title: title,
                    description: description,
                    link: link,
                    price: price.flatMap { $0.isEmpty ? nil : $0 }.map { .some($0) } ?? .null,
                    currency: currency.rawValue
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.createWishItem {
                        let item = WishlistItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: data.link,
                            price: data.price.map { String($0) },
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: data.imageUrl
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось создать желание"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        switch result {
        case .success(let item):
            wishes.insert(item, at: 0)
            return item
        case .failure(let error):
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    @discardableResult
    func updateWish(id: String, title: String, description: String, link: String, price: String?, currency: WishCurrency) async -> WishlistItem? {
        errorMessage = nil
        
        let result: Result<WishlistItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.UpdateWishItemMutation(
                    id: id,
                    title: .some(title),
                    description: .some(description),
                    link: .some(link),
                    price: price.flatMap { $0.isEmpty ? nil : $0 }.map { .some($0) } ?? .null,
                    currency: .some(currency.rawValue)
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.updateWishItem {
                        let item = WishlistItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: data.link,
                            price: data.price.map { String($0) },
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: data.imageUrl
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось обновить желание"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        switch result {
        case .success(let updatedItem):
            if let index = wishes.firstIndex(where: { $0.id == updatedItem.id }) {
                wishes[index] = updatedItem
            }
            return updatedItem
        case .failure(let error):
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func deleteWish(id: String) async -> Bool {
        errorMessage = nil
        
        let result: Result<Bool, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.DeleteWishItemMutation(id: id)
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let success = graphQLResult.data?.deleteWishItem {
                        continuation.resume(returning: .success(success))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось удалить желание"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        switch result {
        case .success(let success):
            if success {
                wishes.removeAll { $0.id == id }
            }
            return success
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    @discardableResult
    func uploadAndAttachImage(itemId: String, imageData: Data, filename: String, contentType: String) async throws -> WishlistItem {
        print("[WishlistService] Starting image upload for item \(itemId), filename: \(filename), size: \(imageData.count) bytes")
        
        let upload = try await createImageUpload(itemId: itemId, filename: filename, contentType: contentType)
        print("[WishlistService] Got presigned upload — key: \(upload.key), url: \(upload.uploadUrl)")
        
        try await uploadImageData(imageData, to: upload.uploadUrl, contentType: contentType)
        print("[WishlistService] PUT to S3 succeeded")
        
        let updatedItem = try await attachImage(itemId: itemId, key: upload.key)
        print("[WishlistService] Image attached — imageUrl: \(updatedItem.imageUrl ?? "nil")")
        
        if let index = wishes.firstIndex(where: { $0.id == updatedItem.id }) {
            wishes[index] = updatedItem
        }
        
        return updatedItem
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    
    // MARK: - Private Methods
    
    private func createImageUpload(itemId: String, filename: String, contentType: String) async throws -> (key: String, uploadUrl: String) {
        let result: Result<(key: String, uploadUrl: String), Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.CreateWishItemImageUploadMutation(
                    id: itemId,
                    filename: filename,
                    contentType: contentType
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.createWishItemImageUpload {
                        continuation.resume(returning: .success((key: data.key, uploadUrl: data.uploadUrl)))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось создать загрузку изображения"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    private func uploadImageData(_ data: Data, to urlString: String, contentType: String) async throws {
        guard let url = URL(string: urlString) else {
            print("[WishlistService] Invalid upload URL: \(urlString)")
            throw NSError(
                domain: "WishlistService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Некорректный URL для загрузки"]
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[WishlistService] S3 upload — no HTTP response")
            throw NSError(
                domain: "WishlistService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить изображение"]
            )
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("[WishlistService] S3 upload failed — status: \(httpResponse.statusCode)")
            throw NSError(
                domain: "WishlistService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить изображение (HTTP \(httpResponse.statusCode))"]
            )
        }
    }
    
    private func attachImage(itemId: String, key: String) async throws -> WishlistItem {
        let result: Result<WishlistItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.AttachWishItemImageMutation(
                    id: itemId,
                    key: key
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.attachWishItemImage {
                        let item = WishlistItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: data.link,
                            price: data.price.map { String($0) },
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) },
                            imageUrl: data.imageUrl
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "WishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось привязать изображение"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
}
