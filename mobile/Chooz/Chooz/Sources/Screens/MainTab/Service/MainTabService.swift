import Foundation
import Apollo

protocol MainTabService {
    func fetchUpcomingEvent() async throws -> EventItem?
    func fetchCollectionsHome() async throws -> [MainTabSectionsPayload.Section]
}

final class MainTabServiceImpl: MainTabService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Methods
    
    func fetchUpcomingEvent() async throws -> EventItem? {
        let result: Result<EventItem?, Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MainTabUpcomingEventQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { [dateFormatter] result in
                switch result {
                case .success(let graphQLResult):
                    let upcomingEvent = graphQLResult.data?.events.first.flatMap { event -> EventItem? in
                        guard let date = dateFormatter.date(from: event.date) else {
                            return nil
                        }
                        
                        return EventItem(
                            id: event.id,
                            title: event.title,
                            description: event.description,
                            link: event.link.flatMap(URL.init(string:)),
                            notifyEnabled: event.notifyEnabled,
                            repeatYearly: event.repeatYearly,
                            date: date
                        )
                    }
                    
                    continuation.resume(returning: .success(upcomingEvent))
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    func fetchCollectionsHome() async throws -> [MainTabSectionsPayload.Section] {
        let result: Result<[MainTabSectionsPayload.Section], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MainTabCollectionsHomeQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    let sections = graphQLResult.data?.collectionsHome.sections.map { section in
                        MainTabSectionsPayload.Section(
                            key: section.key,
                            title: section.title,
                            collections: section.collections.map { collection in
                                MainTabSectionsPayload.Collection(
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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
