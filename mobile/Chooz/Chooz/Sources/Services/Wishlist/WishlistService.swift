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
                            currency: item.currency.flatMap { WishCurrency(rawValue: $0) }
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
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) }
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
    
    func addWish(title: String, description: String, link: String, price: String?, currency: WishCurrency) async {
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
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) }
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
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func updateWish(id: String, title: String, description: String, link: String, price: String?, currency: WishCurrency) async {
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
                            currency: data.currency.flatMap { WishCurrency(rawValue: $0) }
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
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
}
