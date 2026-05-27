import Foundation
import Apollo
import Testing
@testable import Chooz

struct ProfileViewModelTests {

    @Test
    @MainActor
    func shareProfile_presentsShareSheetAfterPublicLinkPreparation() async {
        let url = URL(string: "https://chooz-hse.ru/wishlist/public-token/")!
        let router = ProfileRouterSpy()
        let profileService = ProfileServiceSpy(
            userId: "profile-1",
            firstName: "Alice",
            lastName: "Stone",
            prepareShareLinkResult: .success(url)
        )
        let analytics = ProfileAnalyticsSpy()
        let toast = ToastSpy()
        let viewModel = makeViewModel(
            router: router,
            profileService: profileService,
            analytics: analytics,
            toast: toast
        )

        viewModel.shareProfile()

        #expect(await waitUntil { router.presentedShareItems.count == 1 })
        #expect((router.presentedShareItems.first?.first as? URL) == url)
        #expect(analytics.sharedUserIds == ["profile-1"])
        #expect(toast.errors.isEmpty)
    }

    @Test
    @MainActor
    func shareProfile_showsToastAndSkipsShareSheetWhenPreparationFails() async {
        let router = ProfileRouterSpy()
        let profileService = ProfileServiceSpy(
            userId: "profile-1",
            firstName: "Alice",
            lastName: "Stone",
            prepareShareLinkResult: .failure(ProfileViewModelTestError.failed)
        )
        let analytics = ProfileAnalyticsSpy()
        let toast = ToastSpy()
        let viewModel = makeViewModel(
            router: router,
            profileService: profileService,
            analytics: analytics,
            toast: toast
        )

        viewModel.shareProfile()

        #expect(await waitUntil { !toast.errors.isEmpty })
        #expect(router.presentedShareItems.isEmpty)
        #expect(toast.errors == [("Не удалось поделиться вишлистом", nil)])
        #expect(analytics.sharedUserIds.isEmpty)
    }

    @MainActor
    private func makeViewModel(
        router: ProfileRouterSpy,
        profileService: ProfileServiceSpy,
        analytics: ProfileAnalyticsSpy,
        toast: ToastSpy
    ) -> ProfileViewModel {
        ProfileViewModel(
            router: router,
            profileService: profileService,
            wishlistViewModel: WishlistViewModel(
                wishlistService: WishlistService(
                    apolloClient: ApolloClient(url: URL(string: "https://example.com/graphql")!)
                ),
                toastManager: ToastManager(),
                analytics: WishlistAnalytics(analyticsService: AnalyticsService())
            ),
            analytics: analytics,
            toastManager: toast
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
private final class ProfileRouterSpy: ProfileRouting {
    private(set) var presentedShareItems: [[Any]] = []

    func routeTo(destination: ProfileNavigationDestination) {}

    func presentShareSheet(items: [Any]) {
        presentedShareItems.append(items)
    }
}

@MainActor
private final class ProfileServiceSpy: ProfileServicing {
    var userId: String?
    var firstName: String?
    var lastName: String?
    var isLoading: Bool = false

    init(
        userId: String?,
        firstName: String?,
        lastName: String?,
        prepareShareLinkResult: Result<URL, Error>
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.prepareShareLinkResult = prepareShareLinkResult
    }

    func fetchMe() async {}

    func prepareWishlistShareLink() async throws -> URL {
        try prepareShareLinkResult.get()
    }

    private let prepareShareLinkResult: Result<URL, Error>
}

@MainActor
private final class ProfileAnalyticsSpy: ProfileAnalyticsTracking {
    private(set) var sharedUserIds: [String] = []

    func trackScreenViewed() {}

    func trackProfileShared(userId: String) {
        sharedUserIds.append(userId)
    }

    func setUserProfileID(_ profileID: String) {}
}

@MainActor
private final class ToastSpy: ToastPresenting {
    private(set) var errors: [(String, String?)] = []

    func showError(_ title: String, subtitle: String?) {
        errors.append((title, subtitle))
    }
}

private enum ProfileViewModelTestError: Error {
    case failed
}
