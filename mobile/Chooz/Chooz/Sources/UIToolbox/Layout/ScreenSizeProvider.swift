import Foundation
import UIKit

@MainActor
public enum ScreenSizeProvider {

    // MARK: - Public Properties

    public static var customSimulatorSize: CGSize?

    public static var size: CGSize {
        #if DEBUG && targetEnvironment(simulator)
        return customSimulatorSize ?? UIApplication.shared.mainWindow?.bounds.size ?? UIScreen.main.bounds.size
        #else
        return UIApplication.shared.mainWindow?.bounds.size ?? UIScreen.main.bounds.size
        #endif
    }

}
