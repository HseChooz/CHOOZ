import UIKit

extension UIScreen {

    // MARK: - Internal Properties

    @MainActor
    var currentInterfaceLayout: InterfaceLayout {
        InterfaceLayout()
    }

}
