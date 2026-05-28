import Apollo
import Testing
@testable import Chooz

struct WishlistShareRouteResolverTests {

    @Test
    func resolveUserId_returnsUserIdForSuccessfulPayload() async throws {
        let resolver = WishlistShareRouteResolver { _token, completion in
            completion(.success((userId: "user-123", errors: nil)))
        }

        let userId = try await resolver.resolveUserId(token: "public-token")

        #expect(userId == "user-123")
    }

    @Test
    func resolveUserId_mapsMissingOrDisabledTokenToUnavailableError() async {
        let resolver = WishlistShareRouteResolver { _token, completion in
            completion(
                .success(
                    (
                        userId: nil,
                        errors: [
                            GraphQLError(
                                message: "Wishlist share link not found",
                                extensions: ["code": "WISHLIST_SHARE_NOT_FOUND"]
                            )
                        ]
                    )
                )
            )
        }

        await #expect(throws: WishlistShareRouteResolverError.unavailable) {
            try await resolver.resolveUserId(token: "missing-token")
        }
    }

    @Test
    func resolveUserId_mapsUnknownGraphQLErrorToFailedError() async {
        let resolver = WishlistShareRouteResolver { _token, completion in
            completion(
                .success(
                    (
                        userId: nil,
                        errors: [
                            GraphQLError(
                                message: "Something went wrong",
                                extensions: ["code": "INTERNAL"]
                            )
                        ]
                    )
                )
            )
        }

        do {
            _ = try await resolver.resolveUserId(token: "broken-token")
            Issue.record("Ожидалась ошибка для неизвестного GraphQL-кода")
        } catch let error as WishlistShareRouteResolverError {
            switch error {
            case .failed(let message):
                #expect(message == "Something went wrong")
            default:
                Issue.record("Ожидалась ошибка .failed(message:)")
            }
        } catch {
            Issue.record("Ожидалась ошибка WishlistShareRouteResolverError")
        }
    }
}
