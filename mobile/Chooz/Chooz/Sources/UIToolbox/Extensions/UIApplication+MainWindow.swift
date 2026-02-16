import UIKit

extension UIApplication {

    // MARK: - Internal Properties

    @MainActor
    var mainWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
    }

}
