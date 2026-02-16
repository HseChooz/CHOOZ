import SwiftUI
import UIKit

// MARK: - EnvironmentValues

private struct InterfaceLayoutKey: EnvironmentKey {
    static var defaultValue: InterfaceLayout {
        MainActor.assumeIsolated {
            UIScreen.main.currentInterfaceLayout
        }
    }
}

extension EnvironmentValues {
    public var interfaceLayout: InterfaceLayout {
        get { self[InterfaceLayoutKey.self] }
        set { self[InterfaceLayoutKey.self] = newValue }
    }
}

/// Guide
/// https://nda.ya.ru/t/viXceqTM74W7vN
/// https://screensizes.app
public enum InterfaceLayout: Equatable, Sendable {

    // MARK: - Public Types

    public enum CompactSize: Sendable {
        case small
        case standard
    }

    public enum Orientation: Sendable {
        case portrait
        case landscape
    }

    // MARK: - Cases

    case large(Orientation)
    case compact(CompactSize, Orientation = .portrait)

}

// MARK: - Init

extension InterfaceLayout {

    @MainActor
    public init() {
        self.init(screenSize: ScreenSizeProvider.size)
    }

    public init(screenSize: CGSize) {
        let orientation: Orientation = screenSize.width > screenSize.height ? .landscape : .portrait

        switch orientation {
        case .portrait:
            self = Self(for: screenSize.width, orientation: orientation)
        case .landscape:
            self = Self(for: screenSize.height, orientation: orientation)
        }
    }

    public init(for size: CGFloat, orientation: Orientation) {
        switch size {
        case ..<360:
            self = .compact(.small, orientation)
        case 360..<600:
            self = .compact(.standard, orientation)
        default:
            self = .large(orientation)
        }
    }

}

// MARK: - Protocol CaseIterable

extension InterfaceLayout: CaseIterable {

    public static var allCases: [InterfaceLayout] {
        return [
            .large(.portrait),
            .large(.landscape),
            .compact(.standard, .portrait),
            .compact(.standard, .landscape),
            .compact(.small, .portrait),
            .compact(.small, .landscape)
        ]
    }

}

// MARK: - Comparing Without Orientation

extension InterfaceLayout {

    public func isEqualIgnoringOrientation(to otherLayout: InterfaceLayout) -> Bool {

        switch (self, otherLayout) {
        case (.large, .large):
            return true
        case (.compact(let lhsCompactSize, _), .compact(let rhsCompactSize, _)):
            return lhsCompactSize == rhsCompactSize
        case (.compact, .large), (.large, .compact):
            return false
        }

    }

}
