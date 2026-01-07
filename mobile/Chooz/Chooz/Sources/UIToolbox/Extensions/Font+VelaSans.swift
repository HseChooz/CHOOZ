import SwiftUI

extension Font {
    
    static func velaSans(
        size: CGFloat,
        weight: VelaSansWeight = .regular
    ) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
    
}

enum VelaSansWeight: String, CaseIterable {
    case extraLight
    case light
    case regular
    case medium
    case semiBold
    case bold
    case extraBold
    
    var fontName: String {
        switch self {
        case .extraLight:
            return "VelaSans-ExtraLight"
        case .light:
            return "VelaSans-Light"
        case .regular:
            return "VelaSans-Regular"
        case .medium:
            return "VelaSans-Medium"
        case .semiBold:
            return "VelaSans-SemiBold"
        case .bold:
            return "VelaSans-Bold"
        case .extraBold:
            return "VelaSans-ExtraBold"
        }
    }
    
    init(from fontWeight: Font.Weight) {
        switch fontWeight {
        case .ultraLight:
            self = .extraLight
        case .light:
            self = .light
        case .regular:
            self = .regular
        case .medium:
            self = .medium
        case .semibold:
            self = .semiBold
        case .bold:
            self = .bold
        case .heavy, .black:
            self = .extraBold
        default:
            self = .regular
        }
    }
}
