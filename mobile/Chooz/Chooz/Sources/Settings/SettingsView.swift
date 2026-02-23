import SwiftUI

struct SettingsView: View {
    
    // MARK: - Init
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            headerView
            
            VStack(spacing: 64.0) {
                appSettingsSectionView
                
                accountSettingsSectionView
            }
        }
        .padding(16.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .confirmationDialog(
            isPresented: $isLogoutConfirmationPresented,
            title: "Выход из аккаунта",
            description: "Все ваши данные сохранятся",
            primaryAction: ConfirmationDialogAction(title: "Остаться") {},
            destructiveAction: ConfirmationDialogAction(title: "Все равно выйти") {
                viewModel.logout()
            }
        )
    }
    
    // MARK: - Private Properties
    
    private let viewModel: SettingsViewModel
    
    @State private var isLogoutConfirmationPresented: Bool = false
    
    // MARK: - Private Views
    
    private var headerView: some View {
        Text("Настройки")
            .font(.velaSans(size: 24.0, weight: .bold))
            .foregroundStyle(Colors.Common.black)
    }

    private var appSettingsSectionView: some View {
        VStack(spacing: .zero) {
            SettingsToggleView(title: "Получать уведомления")
                .padding(.vertical, 16.0)
            
            dashDivider
            
            // TODO: uncomment when feature is ready
//            SettingsToggleView(title: "Получать SMS-рассылки")
//                .padding(.vertical, 16.0)
//            
//            dashDivider
            
            SettingsButtonView(
                title: "Пароль и данные",
                style: .neutral,
                hasChevron: true
            )
            .padding(.vertical, 16.0)
            
            dashDivider
            
            SettingsButtonView(
                title: "О приложении",
                style: .neutral,
                hasChevron: true
            )
            .padding(.vertical, 16.0)
            
            dashDivider
        }
    }
    
    private var accountSettingsSectionView: some View {
        VStack(spacing: 16.0) {
            SettingsButtonView(
                title: "Завершить сессию",
                style: .neutral,
                hasChevron: false,
                action: { isLogoutConfirmationPresented = true }
            )
                        
            SettingsButtonView(
                title: "Удалить аккаунт",
                style: .red,
                hasChevron: false
            )
        }
    }
    
    private var dashDivider: some View {
        HorizontalLine()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(Colors.Neutral.grey200)
            .frame(height: 1)
    }
}
