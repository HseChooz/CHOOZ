import Foundation
import Apollo

protocol CollectionService {
    func fetchCollection(slug: String) async throws -> CollectionPayload
}

final class CollectionServiceImpl: CollectionService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Methods
    
    func fetchCollection(slug: String) async throws -> CollectionPayload {
        let result: Result<CollectionPayload, Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.CollectionQuery(slug: slug),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    guard let collection = graphQLResult.data?.collection else {
                        continuation.resume(returning: .failure(CollectionErrorType.notFound))
                        return
                    }
                    
                    continuation.resume(returning: .success(
                        CollectionPayload(
                            id: collection.id,
                            slug: collection.slug,
                            title: collection.title,
                            subtitle: collection.subtitle,
                            description: collection.description,
                            badge: collection.badge,
                            coverImageUrl: collection.coverImageUrl.flatMap(URL.init(string:)),
                            sectionKey: collection.sectionKey,
                            sectionTitle: collection.sectionTitle,
                            tags: collection.tags,
                            itemsCount: collection.itemsCount,
                            items: collection.items.map { item in
                                CollectionPayload.Item(
                                    id: item.id,
                                    title: item.title,
                                    description: item.description,
                                    link: item.link.flatMap(URL.init(string:)),
                                    price: item.price.map { String($0) },
                                    currency: item.currency.flatMap { WishCurrency(rawValue: $0.uppercased()) },
                                    tags: item.tags,
                                    imageUrl: item.imageUrl.flatMap(URL.init(string:)),
                                    isAdded: item.isAdded,
                                    wishItemId: item.wishItemId
                                )
                            }
                        )
                    ))
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    
}
