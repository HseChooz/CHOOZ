import SwiftUI

@MainActor
final class ToastManager {
    
    // MARK: - Internal Methods
    
    func showSuccessBlue(_ title: String) {
        show(model: .successBlue(title: title))
    }
    
    func showSuccessGreen(_ title: String) {
        show(model: .successGreen(title: title))
    }
    
    func showError(_ title: String, subtitle: String? = nil) {
        show(model: .error(title: title, subtitle: subtitle))
    }
    
    func showInfo(_ title: String, subtitle: String? = nil) {
        show(model: .info(title: title, subtitle: subtitle))
    }
    
    // MARK: - Private Properties
    
    private var toastView: UIView?
    private var dismissTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func show(model: ToastModel) {
        if toastView != nil {
            dismissAnimated { [weak self] in
                self?.presentToast(model: model)
            }
        } else {
            presentToast(model: model)
        }
    }
    
    private func presentToast(model: ToastModel) {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let swiftUIView = ToastView(model: model, onDismiss: { [weak self] in
            self?.dismiss()
        })
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        let toastUIView = hostingController.view!
        toastUIView.translatesAutoresizingMaskIntoConstraints = false
        
        keyWindow.addSubview(toastUIView)
        
        NSLayoutConstraint.activate([
            toastUIView.topAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.topAnchor, constant: 10),
            toastUIView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor)
        ])
        
        toastView = toastUIView
        
        toastUIView.alpha = 0
        toastUIView.transform = CGAffineTransform(translationX: 0, y: -50)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            toastUIView.alpha = 1
            toastUIView.transform = .identity
        }
        
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(7))
            dismiss()
        }
    }
    
    private func dismiss() {
        dismissAnimated(completion: nil)
    }
    
    private func dismissAnimated(completion: (() -> Void)?) {
        dismissTask?.cancel()
        dismissTask = nil
        
        guard let view = toastView else {
            completion?()
            return
        }
        toastView = nil
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: -50)
        }, completion: { _ in
            view.removeFromSuperview()
            completion?()
        })
    }
}
