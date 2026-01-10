import SwiftUI

struct AuthorizationView: View {
    
    // MARK: - Init
    
    init(viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel
    }
        
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            Images.Logo.Full.v3
                .resizable()
                .scaledToFill()
                .frame(width: 136.0, height: 26.0)
            
            Text("Аутентификация")
                .font(.velaSans(size: 20.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey900)
            
            loginButtonsView
            
            termsAgreementView
        }
    }
    
    // MARK: - Private Properties
    
    private var viewModel: AuthorizationViewModel
    
    // MARK: - Private Views
    
    private var loginButtonsView: some View {
        VStack(spacing: 8.0) {
            AuthScreenButtonView(
                image: Images.Icons.apple,
                title: "Войти через Apple",
                style: .primary,
                action: {}
            )
            
            AuthScreenButtonView(
                image: Images.Icons.google,
                title: "Войти через Google",
                style: .secondary,
                action: {}
            )
            
            AuthScreenButtonView(
                image: Images.Icons.yandex,
                title: "Войти через Яндекс",
                style: .secondary,
                action: {}
            )
        }
        .padding(.horizontal, 32.0)
    }
    
    private var termsAgreementView: some View {
        Text("Нажимая на кнопку, вы соглашаетесь\nс **[условиями](https://oliverfoggin.com)** использования сервиса\nChooz и **[обработки](https://oliverfoggin.com)** персональных данных")
            .multilineTextAlignment(.center)
            .font(.velaSans(size: 12.0, weight: .bold))
            .tint(Colors.Blue.blue500)
            .foregroundStyle(Colors.Neutral.grey800)
    }
}
