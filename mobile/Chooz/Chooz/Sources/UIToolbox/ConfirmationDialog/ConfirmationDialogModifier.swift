import SwiftUI

// MARK: - View Extension

extension View {
    
    func confirmationDialog(
        isPresented: Binding<Bool>,
        title: String,
        description: String? = nil,
        primaryAction: ConfirmationDialogAction,
        destructiveAction: ConfirmationDialogAction
    ) -> some View {
        modifier(
            ConfirmationDialogModifier(
                isPresented: isPresented,
                title: title,
                description: description,
                primaryAction: primaryAction,
                destructiveAction: destructiveAction
            )
        )
    }
}

// MARK: - ConfirmationDialogModifier

private struct ConfirmationDialogModifier: ViewModifier {
    
    // MARK: - Init
    
    init(
        isPresented: Binding<Bool>,
        title: String,
        description: String?,
        primaryAction: ConfirmationDialogAction,
        destructiveAction: ConfirmationDialogAction
    ) {
        self._isPresented = isPresented
        self.title = title
        self.description = description
        self.primaryAction = primaryAction
        self.destructiveAction = destructiveAction
    }
    
    // MARK: - Protocol ViewModifier
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    ConfirmationDialogPresenter.shared.show(
                        title: title,
                        description: description,
                        primaryAction: primaryAction,
                        destructiveAction: destructiveAction,
                        onDismiss: { isPresented = false }
                    )
                } else {
                    ConfirmationDialogPresenter.shared.hide()
                }
            }
    }
    
    // MARK: - Private Properties
    
    @Binding private var isPresented: Bool
    private let title: String
    private let description: String?
    private let primaryAction: ConfirmationDialogAction
    private let destructiveAction: ConfirmationDialogAction
}

// MARK: - ConfirmationDialogPresenter

@MainActor
private final class ConfirmationDialogPresenter {
    
    static let shared = ConfirmationDialogPresenter()
    
    // MARK: - Internal Methods
    
    func show(
        title: String,
        description: String?,
        primaryAction: ConfirmationDialogAction,
        destructiveAction: ConfirmationDialogAction,
        onDismiss: @escaping () -> Void
    ) {
        guard overlayWindow == nil,
              let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first
        else { return }
        
        let animationState = ConfirmationDialogAnimationState()
        self.animationState = animationState
        
        let dismiss = { [weak self] in
            onDismiss()
            self?.animateHide()
        }
        
        let overlayView = ConfirmationDialogOverlayView(
            title: title,
            description: description,
            primaryAction: primaryAction,
            destructiveAction: destructiveAction,
            animationState: animationState,
            onDismiss: dismiss
        )
        
        let hostingController = UIHostingController(rootView: overlayView)
        hostingController.view.backgroundColor = .clear
        
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        
        overlayWindow = window
    }
    
    func hide() {
        animateHide()
    }
    
    // MARK: - Private Properties
    
    private var overlayWindow: UIWindow?
    private var animationState: ConfirmationDialogAnimationState?
    
    // MARK: - Private Methods
    
    private func animateHide() {
        guard let animationState else {
            removeWindow()
            return
        }
        
        animationState.dismiss { [weak self] in
            self?.removeWindow()
        }
    }
    
    private func removeWindow() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
        animationState = nil
    }
}

// MARK: - ConfirmationDialogAnimationState

@MainActor
private final class ConfirmationDialogAnimationState: ObservableObject {
    
    @Published var isVisible: Bool = false
    
    private var onComplete: (() -> Void)?
    
    func dismiss(completion: @escaping () -> Void) {
        onComplete = completion
        isVisible = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.duration) { [weak self] in
            self?.onComplete?()
            self?.onComplete = nil
        }
    }
}

// MARK: - AnimationConstants

private enum AnimationConstants {
    static let duration: Double = 0.25
    static let showAnimation: Animation = .spring(duration: duration, bounce: 0.15)
    static let hideAnimation: Animation = .easeOut(duration: duration)
}

// MARK: - ConfirmationDialogOverlayView

private struct ConfirmationDialogOverlayView: View {
    
    let title: String
    let description: String?
    let primaryAction: ConfirmationDialogAction
    let destructiveAction: ConfirmationDialogAction
    @ObservedObject var animationState: ConfirmationDialogAnimationState
    let onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Colors.Common.black
                .opacity(animationState.isVisible ? 0.4 : 0.0)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
                .animation(.easeInOut(duration: AnimationConstants.duration), value: animationState.isVisible)
            
            ConfirmationDialogView(
                title: title,
                description: description,
                primaryAction: primaryAction,
                destructiveAction: destructiveAction,
                onDismiss: onDismiss
            )
            .scaleEffect(animationState.isVisible ? 1.0 : 0.85)
            .opacity(animationState.isVisible ? 1.0 : 0.0)
            .animation(
                animationState.isVisible
                    ? AnimationConstants.showAnimation
                    : AnimationConstants.hideAnimation,
                value: animationState.isVisible
            )
        }
        .onAppear {
            animationState.isVisible = true
        }
    }
}
