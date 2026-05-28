import UIKit
import Testing
@testable import Chooz

struct DeepLinkServiceTests {

    @Test
    @MainActor
    func handleCustomWishlistURL_pushesResolvedSocialProfileWhenLoggedIn() async {
        let appRouter = AppRouterSpy()
        let socialProfileFactory = SocialProfileFactorySpy()
        let authState = AuthStateSpy(isLoggedIn: true)
        let resolver = WishlistShareRouteResolverSpy(result: .success("user-42"))
        let toast = DeepLinkToastSpy()
        let service = makeService(
            appRouter: appRouter,
            socialProfileFactory: socialProfileFactory,
            authState: authState,
            resolver: resolver,
            toast: toast
        )

        let handled = service.handle(url: URL(string: "chooz://wishlist/token-123")!)

        #expect(handled == true)
        #expect(await waitUntil { resolver.resolvedTokens == ["token-123"] })
        #expect(await waitUntil { socialProfileFactory.requestedUserIds == ["user-42"] })
        #expect(appRouter.pushedViewControllers.count == 1)
        #expect(toast.errors.isEmpty)
    }

    @Test
    @MainActor
    func handleUniversalLink_parsesWishlistShareToken() async {
        let appRouter = AppRouterSpy()
        let socialProfileFactory = SocialProfileFactorySpy()
        let authState = AuthStateSpy(isLoggedIn: true)
        let resolver = WishlistShareRouteResolverSpy(result: .success("user-99"))
        let toast = DeepLinkToastSpy()
        let service = makeService(
            appRouter: appRouter,
            socialProfileFactory: socialProfileFactory,
            authState: authState,
            resolver: resolver,
            toast: toast
        )

        let handled = service.handle(url: URL(string: "https://chooz-hse.ru/wishlist/public-token/")!)

        #expect(handled == true)
        #expect(await waitUntil { resolver.resolvedTokens == ["public-token"] })
        #expect(await waitUntil { socialProfileFactory.requestedUserIds == ["user-99"] })
    }

    @Test
    @MainActor
    func queueAndConsumePendingDeepLink_survivesLoginFlow() async {
        let appRouter = AppRouterSpy()
        let socialProfileFactory = SocialProfileFactorySpy()
        let authState = AuthStateSpy(isLoggedIn: false)
        let resolver = WishlistShareRouteResolverSpy(result: .success("user-77"))
        let toast = DeepLinkToastSpy()
        let service = makeService(
            appRouter: appRouter,
            socialProfileFactory: socialProfileFactory,
            authState: authState,
            resolver: resolver,
            toast: toast
        )

        let queued = service.queue(url: URL(string: "https://chooz-hse.ru/wishlist/pending-token/")!)
        #expect(queued == true)
        #expect(service.pendingDeepLink == .wishlistShare(token: "pending-token"))

        authState.isLoggedIn = true
        service.consumePendingDeepLink()

        #expect(await waitUntil { resolver.resolvedTokens == ["pending-token"] })
        #expect(await waitUntil { socialProfileFactory.requestedUserIds == ["user-77"] })
        #expect(service.pendingDeepLink == nil)
    }

    @Test
    @MainActor
    func handleWishlistShareShowsUnavailableToastForMissingToken() async {
        let appRouter = AppRouterSpy()
        let socialProfileFactory = SocialProfileFactorySpy()
        let authState = AuthStateSpy(isLoggedIn: true)
        let resolver = WishlistShareRouteResolverSpy(result: .failure(WishlistShareRouteResolverError.unavailable))
        let toast = DeepLinkToastSpy()
        let service = makeService(
            appRouter: appRouter,
            socialProfileFactory: socialProfileFactory,
            authState: authState,
            resolver: resolver,
            toast: toast
        )

        let handled = service.handle(url: URL(string: "chooz://wishlist/missing-token")!)

        #expect(handled == true)
        #expect(await waitUntil { !toast.errors.isEmpty })
        #expect(toast.errors == [("Ссылка недоступна", nil)])
        #expect(appRouter.pushedViewControllers.isEmpty)
    }

    @MainActor
    private func makeService(
        appRouter: AppRouterSpy,
        socialProfileFactory: SocialProfileFactorySpy,
        authState: AuthStateSpy,
        resolver: WishlistShareRouteResolverSpy,
        toast: DeepLinkToastSpy
    ) -> DeepLinkService {
        DeepLinkService(
            appRouter: appRouter,
            socialProfileFactory: socialProfileFactory,
            tokenStorage: authState,
            wishlistShareRouteResolver: resolver,
            toastManager: toast,
            universalLinkHost: "chooz-hse.ru"
        )
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        intervalNanoseconds: UInt64 = 20_000_000,
        condition: @escaping @Sendable () -> Bool
    ) async -> Bool {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds
        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return true
            }
            try? await Task.sleep(nanoseconds: intervalNanoseconds)
        }
        return condition()
    }
}

@MainActor
private final class AppRouterSpy: AppRouting {
    private(set) var pushedViewControllers: [UIViewController] = []

    func push(_ viewController: UIViewController, animated: Bool, hideBackButton: Bool) {
        pushedViewControllers.append(viewController)
    }
}

@MainActor
private final class SocialProfileFactorySpy: SocialProfileScreenBuilding {
    private(set) var requestedUserIds: [String] = []

    func makeScreen(userId: String) -> UIViewController {
        requestedUserIds.append(userId)
        return UIViewController()
    }
}

@MainActor
private final class AuthStateSpy: AuthStateProviding {
    var isLoggedIn: Bool

    init(isLoggedIn: Bool) {
        self.isLoggedIn = isLoggedIn
    }
}

@MainActor
private final class WishlistShareRouteResolverSpy: WishlistShareRouteResolving {
    private(set) var resolvedTokens: [String] = []
    private let result: Result<String, Error>

    init(result: Result<String, Error>) {
        self.result = result
    }

    func resolveUserId(token: String) async throws -> String {
        resolvedTokens.append(token)
        return try result.get()
    }
}

@MainActor
private final class DeepLinkToastSpy: ToastPresenting {
    private(set) var errors: [(String, String?)] = []

    func showSuccessBlue(_ title: String) {}

    func showInfo(_ title: String, subtitle: String?) {}

    func showError(_ title: String, subtitle: String?) {
        errors.append((title, subtitle))
    }
}
