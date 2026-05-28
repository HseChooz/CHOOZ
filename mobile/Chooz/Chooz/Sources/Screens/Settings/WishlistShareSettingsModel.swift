import Foundation
import Observation
import UIKit

@MainActor
protocol WishlistSharePresenting: AnyObject {
    func presentShareSheet(items: [Any])
}

@MainActor
protocol ClipboardWriting: AnyObject {
    func copy(text: String)
}

@MainActor
final class ClipboardWriter: ClipboardWriting {
    func copy(text: String) {
        UIPasteboard.general.string = text
    }
}

@MainActor
@Observable
final class WishlistShareSettingsModel {

    // MARK: - Init

    init(
        profileService: any ProfileServicing,
        toastManager: any ToastPresenting,
        sharePresenter: any WishlistSharePresenting,
        clipboard: any ClipboardWriting
    ) {
        self.profileService = profileService
        self.toastManager = toastManager
        self.sharePresenter = sharePresenter
        self.clipboard = clipboard
    }

    // MARK: - Internal Properties

    var isEnabled: Bool = false {
        didSet {
            guard !isApplyingRemoteState, isEnabled != oldValue else { return }
            handleToggleChange(previousValue: oldValue)
        }
    }

    private(set) var isLoading: Bool = false

    var statusText: String {
        if isLoading && shareLink == nil {
            return "Загружаем настройки публичной ссылки."
        }
        if isEnabled {
            return "Ссылка активна. Ей можно делиться с людьми вне приложения."
        }
        if shareLink != nil {
            return "Публичный доступ выключен. Старая ссылка больше не откроет вишлист."
        }
        return "Публичный доступ выключен. Включи его, чтобы делиться вишлистом в браузере."
    }

    var linkText: String? {
        shareLink?.url.absoluteString
    }

    var canShare: Bool {
        !isLoading && isEnabled && shareLink != nil
    }

    var canCopy: Bool {
        canShare
    }

    var canRegenerate: Bool {
        canShare
    }

    // MARK: - Internal Methods

    func onAppear() {
        guard !hasLoaded else { return }
        hasLoaded = true
        refresh(showError: true)
    }

    func shareLinkAction() {
        guard canShare, let url = shareLink?.url else { return }
        sharePresenter.presentShareSheet(items: [url])
    }

    func copyLinkAction() {
        guard canCopy, let linkText else { return }
        clipboard.copy(text: linkText)
        toastManager.showSuccessBlue("Ссылка скопирована")
    }

    func regenerateLinkAction() {
        guard canRegenerate else { return }
        performAction(
            loadingTitle: nil,
            successTitle: "Ссылка обновлена",
            failureTitle: "Не удалось обновить ссылку"
        ) {
            try await self.profileService.regenerateWishlistShareLink()
        }
    }

    // MARK: - Private Properties

    private let profileService: any ProfileServicing
    private let toastManager: any ToastPresenting
    private let sharePresenter: any WishlistSharePresenting
    private let clipboard: any ClipboardWriting

    private var shareLink: WishlistShareLinkState?
    private var hasLoaded: Bool = false
    private var isApplyingRemoteState: Bool = false
    private var task: Task<Void, Never>?

    // MARK: - Private Methods

    private func refresh(showError: Bool) {
        task?.cancel()
        task = Task { @MainActor in
            isLoading = true
            defer {
                isLoading = false
                task = nil
            }

            do {
                let state = try await profileService.fetchWishlistShareLink()
                apply(state: state)
            } catch {
                if showError {
                    toastManager.showError("Не удалось загрузить публичную ссылку", subtitle: nil)
                }
            }
        }
    }

    private func handleToggleChange(previousValue: Bool) {
        let previousState = shareLink
        performAction(
            loadingTitle: nil,
            successTitle: isEnabled ? "Публичная ссылка включена" : "Публичная ссылка отключена",
            failureTitle: isEnabled ? "Не удалось включить публичную ссылку" : "Не удалось отключить публичную ссылку",
            revert: {
                self.apply(state: previousState)
                self.setEnabled(previousValue)
            }
        ) {
            if self.isEnabled {
                return try await self.profileService.prepareWishlistShareLinkState()
            }
            return try await self.profileService.disableWishlistShareLink()
        }
    }

    private func performAction(
        loadingTitle: String?,
        successTitle: String?,
        failureTitle: String,
        revert: (() -> Void)? = nil,
        operation: @escaping @MainActor () async throws -> WishlistShareLinkState
    ) {
        guard task == nil else { return }
        task = Task { @MainActor in
            isLoading = true
            if let loadingTitle {
                toastManager.showInfo(loadingTitle, subtitle: nil)
            }

            defer {
                isLoading = false
                task = nil
            }

            do {
                let state = try await operation()
                apply(state: state)
                if let successTitle {
                    toastManager.showSuccessBlue(successTitle)
                }
            } catch {
                revert?()
                toastManager.showError(failureTitle, subtitle: nil)
            }
        }
    }

    private func apply(state: WishlistShareLinkState?) {
        shareLink = state
        setEnabled(state?.isEnabled ?? false)
    }

    private func setEnabled(_ value: Bool) {
        isApplyingRemoteState = true
        isEnabled = value
        isApplyingRemoteState = false
    }
}
