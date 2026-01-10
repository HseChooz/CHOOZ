import SwiftUI

struct AuthScreenView: View {
    
    // MARK: - Init
    
    init(viewModel: AuthScreenViewModel) {
        self.viewModel = viewModel
    }
        
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            Images.Logo.Full.v3
                .resizable()
                .scaledToFill()
                .frame(width: 136.0, height: 26.0)
            
            Text(AuthScreenStrings.auth)
                .font(.velaSans(size: 20.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey900)
            
            loginButtonsView
            
            termsAgreementView
        }
    }
    
    // MARK: - Private Properties
    
    private var viewModel: AuthScreenViewModel
    
    // MARK: - Private Views
    
    private var loginButtonsView: some View {
        VStack(spacing: 8.0) {
            AuthScreenButtonView(
                image: Images.Icons.apple,
                title: AuthScreenStrings.signInWithApple,
                style: .primary,
                action: {}
            )
            
            AuthScreenButtonView(
                image: Images.Icons.google,
                title: AuthScreenStrings.signInWithGoogle,
                style: .secondary,
                action: {}
            )
            
            AuthScreenButtonView(
                image: Images.Icons.yandex,
                title: AuthScreenStrings.signInWithYandex,
                style: .secondary,
                action: {}
            )
        }
        .padding(.horizontal, 32.0)
    }
    
    private var termsAgreementView: some View {
        AuthScreenStrings.termsAgreement()
            .multilineTextAlignment(.center)
            .font(.velaSans(size: 12.0, weight: .bold))
            .tint(Colors.Blue.blue500)
            .foregroundStyle(Colors.Neutral.grey800)
    }
}
