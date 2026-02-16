import SwiftUI
import Observation

@MainActor
@Observable
final class AuthorizationViewModel {
    
    // MARK: - Init
    
    init(
        interactor: AuthorizationInteractor,
        router: AuthorizationRouter,
        toastManager: ToastManager
    ) {
        self.interactor = interactor
        self.router = router
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Properties
    
    private(set) var isLoading = false
    
    // MARK: - Internal Methods
    
    func signInWithGoogle() {
        signInTask?.cancel()
        isLoading = true
        
        signInTask = Task {
            do {
                try await interactor.signInWithGoogle()
                router.routeToMainScreen()
            } catch let error as AuthError {
                if let content = error.toastContent {
                    toastManager.showError(content.title, subtitle: content.subtitle)
                }
                print("Sign in with Google error: \(error)")
            } catch {
                toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
            
            isLoading = false
        }
    }
    
    func signInWithYandex() {
        signInTask?.cancel()
        isLoading = true
        
        signInTask = Task {
            do {
                try await interactor.signInWithYandex()
                router.routeToMainScreen()
            } catch let error as AuthError {
                if let content = error.toastContent {
                    toastManager.showError(content.title, subtitle: content.subtitle)
                }
                print("Sign in with Yandex error: \(error.localizedDescription)")
            } catch {
                toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: AuthorizationInteractor
    private let router: AuthorizationRouter
    private let toastManager: ToastManager
    
    private var signInTask: Task<Void, Never>?
}
