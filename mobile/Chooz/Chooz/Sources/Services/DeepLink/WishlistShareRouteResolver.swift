import Foundation
import Apollo

enum WishlistShareRouteResolverError: Error, Equatable {
    case unavailable
    case unauthorized
    case failed(message: String?)
}

protocol WishlistShareRouteResolving: AnyObject {
    func resolveUserId(token: String) async throws -> String
}

final class WishlistShareRouteResolver: WishlistShareRouteResolving {

    typealias FetchPayload = (userId: String?, errors: [GraphQLError]?)
    typealias Fetcher = (
        _ token: String,
        _ completion: @escaping (Result<FetchPayload, Error>) -> Void
    ) -> Void

    init(apolloClient: ApolloClient) {
        self.fetcher = { token, completion in
            apolloClient.fetch(
                query: ChoozAPI.WishlistShareTargetQuery(token: token),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    completion(
                        .success(
                            (
                                userId: graphQLResult.data?.wishlistShareTarget?.userId,
                                errors: graphQLResult.errors
                            )
                        )
                    )

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    init(fetcher: @escaping Fetcher) {
        self.fetcher = fetcher
    }

    func resolveUserId(token: String) async throws -> String {
        let result: Result<String, Error> = await withCheckedContinuation { continuation in
            fetcher(token) { fetchResult in
                switch fetchResult {
                case .success(let payload):
                    if let userId = payload.userId {
                        continuation.resume(returning: .success(userId))
                    } else if let firstError = payload.errors?.first {
                        continuation.resume(
                            returning: .failure(Self.mapGraphQLError(firstError))
                        )
                    } else {
                        continuation.resume(
                            returning: .failure(
                                WishlistShareRouteResolverError.failed(message: "Не удалось определить получателя ссылки")
                            )
                        )
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }

    private let fetcher: Fetcher

    private static func mapGraphQLError(_ error: GraphQLError) -> WishlistShareRouteResolverError {
        let code = (error.extensions?["code"] as? String)?.uppercased()
        switch code {
        case "WISHLIST_SHARE_NOT_FOUND", "WISHLIST_SHARE_DISABLED":
            return .unavailable
        case "UNAUTHORIZED":
            return .unauthorized
        default:
            return .failed(message: error.message)
        }
    }
}
