import Foundation
import Apollo

protocol CollectionsListService {
    func fetchCollectionSections(search: String?) async throws -> [CollectionsListPayload]
}

final class CollectionsListServiceImpl: CollectionsListService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Methods
    
    func fetchCollectionSections(search: String?) async throws -> [CollectionsListPayload] {
        let result: Result<[CollectionsListPayload], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.CollectionsListSectionsQuery(
                    search: search.map { .some($0) } ?? .null
                ),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    let sections = graphQLResult.data?.collectionSections.map { section in
                        CollectionsListPayload(
                            sectionId: section.key,
                            title: section.title,
                            collections: section.collections.map { collection in
                                CollectionsListPayload.Collection(
                                    id: collection.id,
                                    slug: collection.slug,
                                    title: collection.title,
                                    subtitle: collection.subtitle,
                                    badge: collection.badge,
                                    coverImageUrl: collection.coverImageUrl.flatMap(URL.init(string:)),
                                    itemsCount: collection.itemsCount
                                )
                            }
                        )
                    } ?? []
                    
                    continuation.resume(returning: .success(sections))
                    
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
