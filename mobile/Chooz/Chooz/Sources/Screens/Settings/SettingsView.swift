import SwiftUI

struct SettingsView<ViewModel: SettingsViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel, wishlistShareModel: WishlistShareSettingsModel) {
        self.viewModel = viewModel
        self.wishlistShareModel = wishlistShareModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            headerView
            
            VStack(spacing: 64.0) {
                appSettingsSectionView
                wishlistShareSectionView
                
                accountSettingsSectionView
            }
        }
        .padding(16.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .onAppear {
            viewModel.onAppear()
            wishlistShareModel.onAppear()
        }
        .confirmationDialog(
            isPresented: $isLogoutConfirmationPresented,
            title: "Выход из аккаунта",
            description: "Все ваши данные сохранятся",
            primaryAction: ConfirmationDialogAction(title: "Остаться") {},
            destructiveAction: ConfirmationDialogAction(title: "Все равно выйти") {
                viewModel.logout()
            }
        )
        .confirmationDialog(
            isPresented: $isDeleteAccountConfirmationPresented,
            title: "Вы уверены, что хотите удалить аккаунт?",
            description: "После удаления аккаунта ваши данные будут утеряны безвозвратно",
            primaryAction: ConfirmationDialogAction(title: "Остаться") {},
            destructiveAction: ConfirmationDialogAction(title: "Удалить") {
                viewModel.deleteAccount()
            }
        )
        .confirmationDialog(
            isPresented: $isRegenerateWishlistLinkConfirmationPresented,
            title: "Обновить публичную ссылку?",
            description: "Старая ссылка перестанет открывать вишлист.",
            primaryAction: ConfirmationDialogAction(title: "Оставить текущую") {},
            destructiveAction: ConfirmationDialogAction(title: "Обновить") {
                wishlistShareModel.regenerateLinkAction()
            }
        )
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    @Bindable private var wishlistShareModel: WishlistShareSettingsModel
    
    @State private var isLogoutConfirmationPresented: Bool = false
    @State private var isDeleteAccountConfirmationPresented: Bool = false
    @State private var isRegenerateWishlistLinkConfirmationPresented: Bool = false
    
    // MARK: - Private Views
    
    private var headerView: some View {
        Text("Настройки")
            .font(.velaSans(size: 24.0, weight: .bold))
            .foregroundStyle(Colors.Common.black)
    }

    private var appSettingsSectionView: some View {
        VStack(spacing: 16.0) {
            SettingsToggleView(
                title: "Получать уведомления",
                isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { viewModel.notificationsEnabled = $0 }
                )
            )
            .padding(.vertical, 16.0)
            
            dashDivider
            
            if viewModel.isDebugPannelAvailable {
                SettingsButtonView(
                    title: "🐞 Дебаг панель",
                    style: .neutral,
                    hasChevron: false,
                    action: {
                        viewModel.openDebugPanel()
                    }
                )
            }
        }
    }

    private var wishlistShareSectionView: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            SettingsToggleView(
                title: "Публичный вишлист",
                isOn: Binding(
                    get: { wishlistShareModel.isEnabled },
                    set: { wishlistShareModel.isEnabled = $0 }
                )
            )
            .padding(.vertical, 16.0)

            VStack(alignment: .leading, spacing: 8.0) {
                Text(wishlistShareModel.statusText)
                    .font(.velaSans(size: 14.0, weight: .semiBold))
                    .foregroundStyle(Colors.Neutral.grey600)

                if let linkText = wishlistShareModel.linkText {
                    Text(linkText)
                        .font(.velaSans(size: 13.0, weight: .semiBold))
                        .foregroundStyle(Colors.Blue.blue500)
                        .lineLimit(2)
                        .textSelection(.enabled)
                }
            }

            dashDivider

            VStack(spacing: 16.0) {
                SettingsButtonView(
                    title: "Поделиться ссылкой",
                    style: .neutral,
                    hasChevron: false,
                    systemIconName: "square.and.arrow.up",
                    isDisabled: !wishlistShareModel.canShare,
                    action: {
                        wishlistShareModel.shareLinkAction()
                    }
                )

                SettingsButtonView(
                    title: "Скопировать ссылку",
                    style: .neutral,
                    hasChevron: false,
                    systemIconName: "doc.on.doc",
                    isDisabled: !wishlistShareModel.canCopy,
                    action: {
                        wishlistShareModel.copyLinkAction()
                    }
                )

                SettingsButtonView(
                    title: "Обновить ссылку",
                    style: .neutral,
                    hasChevron: false,
                    systemIconName: "arrow.clockwise",
                    isDisabled: !wishlistShareModel.canRegenerate,
                    action: {
                        isRegenerateWishlistLinkConfirmationPresented = true
                    }
                )
            }
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
                hasChevron: false,
                action: { isDeleteAccountConfirmationPresented = true }
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
