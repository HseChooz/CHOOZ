import SwiftUI

enum AuthScreenStrings {
    
    // MARK: - Title
    
    static let auth = "Аутентификация"
    
    // MARK: - Buttons
    
    static let signInWithApple = "Войти через Apple"
    static let signInWithGoogle = "Войти через Google"
    static let signInWithYandex = "Войти через Яндекс"
    
    // MARK: - Terms Agreement
        
    static let termsOfUseURL = "https://oliverfoggin.com"
    static let personalDataURL = "https://oliverfoggin.com"
    
    static func termsAgreement(
        termsOfUseURL: String = termsOfUseURL,
        personalDataURL: String = personalDataURL
    ) -> Text {
        Text("Нажимая на кнопку, вы соглашаетесь\nс **[условиями](\(termsOfUseURL))** использования сервиса\nChooz и **[обработки](\(personalDataURL))** персональных данных")
    }
}
