import Foundation

@MainActor
struct AuthorizationFactoryDepsImpl: AuthorizationFactoryDeps {
    let appRouter: AppRouter
    let appleAuthService: AppleAuthService
    let googleAuthService: GoogleAuthService
    let yandexAuthService: YandexAuthService
    let appTabBarFactory: AppTabBarFactory
    let deepLinkService: DeepLinkService
    let analyticsService: AnalyticsService
    let toastManager: ToastManager
}
