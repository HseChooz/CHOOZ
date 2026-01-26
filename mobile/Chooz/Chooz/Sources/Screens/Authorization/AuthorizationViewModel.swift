import SwiftUI
import Observation

@MainActor
@Observable
final class AuthorizationViewModel {
    
    // MARK: - Init
    
    init(interactor: AuthorizationInteractor, toastManager: ToastManager) {
        self.interactor = interactor
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
            } catch let error as AuthError {
                if let content = error.toastContent {
                    toastManager.showError(content.title, subtitle: content.subtitle)
                }
            } catch {
                toastManager.showError("Что-то пошло не так", subtitle: "Произошла непредвиденная ошибка")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Private Properties
    
    private let interactor: AuthorizationInteractor
    private let toastManager: ToastManager
    
    private var signInTask: Task<Void, Never>?
}
