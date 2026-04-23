import Foundation
import Observation
import SwiftUI

@MainActor
protocol AuthorizationViewModelDeps {
    var toastManager: ToastManager { get }
}

@MainActor
@Observable
final class AuthorizationViewModel {
    
    // MARK: - Init
    
    init(
        interactor: AuthorizationInteractor,
        router: AuthorizationRouter,
        analytics: AuthorizationAnalytics,
        deps: AuthorizationViewModelDeps
    ) {
        self.interactor = interactor
        self.router = router
        self.analytics = analytics
        self.deps = deps
    }
    
    // MARK: - Internal Properties
    
    private(set) var isLoading = false
    
    // MARK: - Internal Methods
    
    func signInWithApple() {
        signInTask?.cancel()
        isLoading = true
        
        signInTask = Task {
            defer { isLoading = false }
            
            do {
                try await interactor.signInWithApple()
                analytics.trackAuthCompleted(provider: "apple")
                router.routeToMainScreen()
            } catch let error as AuthError {
                if let content = error.toastContent {
                    deps.toastManager.showError(content.title, subtitle: content.subtitle)
                }
                print("AuthorizationViewModel signInWithApple AuthError=\(error) toastShown=\(error.toastContent != nil)")
            } catch {
                let ns = error as NSError
                print("AuthorizationViewModel signInWithApple non-AuthError type=\(Swift.type(of: error)) describing=\(String(describing: error))")
                print("AuthorizationViewModel signInWithApple NSError domain=\(ns.domain) code=\(ns.code) userInfo=\(ns.userInfo)")
                deps.toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
        }
    }
    
    func signInWithGoogle() {
        signInTask?.cancel()
        isLoading = true
        
        signInTask = Task {
            defer { isLoading = false }
            
            do {
                try await interactor.signInWithGoogle()
                analytics.trackAuthCompleted(provider: "google")
                router.routeToMainScreen()
            } catch let error as AuthError {
                if let content = error.toastContent {
                    deps.toastManager.showError(content.title, subtitle: content.subtitle)
                }
                print("Sign in with Google error: \(error)")
            } catch {
                deps.toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
        }
    }
    
    func signInWithYandex() {
        signInTask?.cancel()
        isLoading = true
        
        signInTask = Task {
            defer { isLoading = false }
            
            do {
                try await interactor.signInWithYandex()
                analytics.trackAuthCompleted(provider: "yandex")
                router.routeToMainScreen()
            } catch let error as AuthError {
                if let content = error.toastContent {
                    deps.toastManager.showError(content.title, subtitle: content.subtitle)
                }
                print("Sign in with Yandex error: \(error.localizedDescription)")
            } catch {
                deps.toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: AuthorizationInteractor
    private let router: AuthorizationRouter
    private let analytics: AuthorizationAnalytics
    private let deps: AuthorizationViewModelDeps
    
    private var signInTask: Task<Void, Never>?
}
