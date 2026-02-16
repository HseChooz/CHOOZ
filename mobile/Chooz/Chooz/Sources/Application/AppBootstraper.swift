import UIKit
import SwiftUI

@MainActor
final class AppBootstraper {
    
    // MARK: - Init
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - Internal Methods
    
    func start() {
        clearKeychainIfNeeded()
        
        let splashVC = UIHostingController(rootView: SplashView())
        appContainer.appRouter.setRoot(splashVC)
        
        if !appContainer.userDefaultsService.hasSeenOnboarding {
            routeAfterDelay {
                self.appContainer.onboardingFactory.makeScreen()
            }
        } else if appContainer.tokenStorage.isLoggedIn {
            validateSessionAndRoute()
        } else {
            routeAfterDelay {
                self.appContainer.authorizationFactory.makeScreen()
            }
        }
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let splashDurationNanoseconds: UInt64 = 3_000_000_000
        static let validationTimeoutNanoseconds: UInt64 = 10_000_000_000
    }
    
    // MARK: - Private Properties
    
    private let appContainer: AppContainer
    
    // MARK: - Private Methods
    
    private func clearKeychainIfNeeded() {
        guard appContainer.userDefaultsService.isFirstLaunchAfterInstall else { return }
        appContainer.tokenStorage.clear()
        appContainer.userDefaultsService.markAsLaunched()
    }
    
    private func routeAfterDelay(makeViewController: @escaping @MainActor () -> UIViewController) {
        Task {
            try? await Task.sleep(nanoseconds: Static.splashDurationNanoseconds)
            let vc = makeViewController()
            appContainer.appRouter.setRoot(vc)
        }
    }
    
    private func validateSessionAndRoute() {
        Task {
            let result = await validateWithTimeout()
            
            switch result {
            case .valid, .networkError:
                let vc = appContainer.mainTabBarFactory.makeScreen()
                appContainer.appRouter.setRoot(vc)
            case .invalid:
                appContainer.sessionService.handleSessionExpired()
            }
        }
    }
    
    private func validateWithTimeout() async -> SessionValidationResult {
        await withTaskGroup(of: SessionValidationResult.self) { group in
            group.addTask {
                await self.appContainer.sessionService.validateSession()
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: Static.validationTimeoutNanoseconds)
                return .networkError
            }
            
            let first = await group.next() ?? .networkError
            group.cancelAll()
            return first
        }
    }
}
