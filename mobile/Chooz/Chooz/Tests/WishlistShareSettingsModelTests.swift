import Foundation
import Testing
@testable import Chooz

struct WishlistShareSettingsModelTests {

    @Test
    @MainActor
    func onAppear_loadsExistingShareLink() async {
        let profileService = WishlistShareProfileServiceSpy()
        profileService.fetchShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: true
            )
        )
        let model = makeModel(profileService: profileService)

        model.onAppear()

        #expect(await waitUntil { model.linkText != nil })
        #expect(model.isEnabled == true)
        #expect(model.linkText == "https://chooz-hse.ru/wishlist/abc/")
        #expect(model.canShare == true)
    }

    @Test
    @MainActor
    func disablingLink_callsDisableAndUpdatesState() async {
        let profileService = WishlistShareProfileServiceSpy()
        profileService.fetchShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: true
            )
        )
        profileService.disableShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: false
            )
        )
        let toast = WishlistShareToastSpy()
        let model = makeModel(profileService: profileService, toast: toast)

        model.onAppear()
        #expect(await waitUntil { model.canShare })

        model.isEnabled = false

        #expect(await waitUntil { profileService.disableCalls == 1 })
        #expect(model.isEnabled == false)
        #expect(model.canShare == false)
        #expect(toast.successMessages.contains("Публичная ссылка отключена"))
    }

    @Test
    @MainActor
    func shareLink_presentsShareSheetWithCurrentUrl() async {
        let profileService = WishlistShareProfileServiceSpy()
        profileService.fetchShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: true
            )
        )
        let presenter = WishlistSharePresenterSpy()
        let model = makeModel(profileService: profileService, presenter: presenter)

        model.onAppear()
        #expect(await waitUntil { model.canShare })

        model.shareLinkAction()

        #expect((presenter.presentedItems.first?.first as? URL)?.absoluteString == "https://chooz-hse.ru/wishlist/abc/")
    }

    @Test
    @MainActor
    func copyLink_copiesUrlAndShowsToast() async {
        let profileService = WishlistShareProfileServiceSpy()
        profileService.fetchShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: true
            )
        )
        let toast = WishlistShareToastSpy()
        let clipboard = ClipboardSpy()
        let model = makeModel(profileService: profileService, toast: toast, clipboard: clipboard)

        model.onAppear()
        #expect(await waitUntil { model.canCopy })

        model.copyLinkAction()

        #expect(clipboard.copiedText == "https://chooz-hse.ru/wishlist/abc/")
        #expect(toast.successMessages.contains("Ссылка скопирована"))
    }

    @Test
    @MainActor
    func regenerateLink_updatesUrlAndShowsToast() async {
        let profileService = WishlistShareProfileServiceSpy()
        profileService.fetchShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/abc/")!,
                isEnabled: true
            )
        )
        profileService.regenerateShareLinkResult = .success(
            WishlistShareLinkState(
                url: URL(string: "https://chooz-hse.ru/wishlist/xyz/")!,
                isEnabled: true
            )
        )
        let toast = WishlistShareToastSpy()
        let model = makeModel(profileService: profileService, toast: toast)

        model.onAppear()
        #expect(await waitUntil { model.canRegenerate })

        model.regenerateLinkAction()

        #expect(await waitUntil { profileService.regenerateCalls == 1 })
        #expect(model.linkText == "https://chooz-hse.ru/wishlist/xyz/")
        #expect(toast.successMessages.contains("Ссылка обновлена"))
    }

    @MainActor
    private func makeModel(
        profileService: WishlistShareProfileServiceSpy,
        toast: WishlistShareToastSpy = WishlistShareToastSpy(),
        presenter: WishlistSharePresenterSpy = WishlistSharePresenterSpy(),
        clipboard: ClipboardSpy = ClipboardSpy()
    ) -> WishlistShareSettingsModel {
        WishlistShareSettingsModel(
            profileService: profileService,
            toastManager: toast,
            sharePresenter: presenter,
            clipboard: clipboard
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
private final class WishlistShareProfileServiceSpy: ProfileServicing {
    var userId: String? = "profile-1"
    var firstName: String? = "Alice"
    var lastName: String? = "Stone"
    var isLoading: Bool = false

    var fetchShareLinkResult: Result<WishlistShareLinkState?, Error> = .success(nil)
    var disableShareLinkResult: Result<WishlistShareLinkState, Error> = .failure(WishlistShareSettingsTestError.failed)
    var regenerateShareLinkResult: Result<WishlistShareLinkState, Error> = .failure(WishlistShareSettingsTestError.failed)

    private(set) var disableCalls: Int = 0
    private(set) var regenerateCalls: Int = 0

    func fetchMe() async {}

    func fetchWishlistShareLink() async throws -> WishlistShareLinkState? {
        try fetchShareLinkResult.get()
    }

    func prepareWishlistShareLink() async throws -> URL {
        try await prepareWishlistShareLinkState().url
    }

    func prepareWishlistShareLinkState() async throws -> WishlistShareLinkState {
        try fetchShareLinkResult.get() ?? WishlistShareLinkState(
            url: URL(string: "https://chooz-hse.ru/wishlist/new/")!,
            isEnabled: true
        )
    }

    func disableWishlistShareLink() async throws -> WishlistShareLinkState {
        disableCalls += 1
        return try disableShareLinkResult.get()
    }

    func regenerateWishlistShareLink() async throws -> WishlistShareLinkState {
        regenerateCalls += 1
        return try regenerateShareLinkResult.get()
    }
}

@MainActor
private final class WishlistShareToastSpy: ToastPresenting {
    private(set) var successMessages: [String] = []
    private(set) var infoMessages: [(String, String?)] = []
    private(set) var errorMessages: [(String, String?)] = []

    func showSuccessBlue(_ title: String) {
        successMessages.append(title)
    }

    func showInfo(_ title: String, subtitle: String?) {
        infoMessages.append((title, subtitle))
    }

    func showError(_ title: String, subtitle: String?) {
        errorMessages.append((title, subtitle))
    }
}

@MainActor
private final class WishlistSharePresenterSpy: WishlistSharePresenting {
    private(set) var presentedItems: [[Any]] = []

    func presentShareSheet(items: [Any]) {
        presentedItems.append(items)
    }
}

@MainActor
private final class ClipboardSpy: ClipboardWriting {
    private(set) var copiedText: String?

    func copy(text: String) {
        copiedText = text
    }
}

private enum WishlistShareSettingsTestError: Error {
    case failed
}
