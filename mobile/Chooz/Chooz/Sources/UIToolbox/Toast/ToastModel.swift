import SwiftUI

enum ToastModel {
    case successGreen(title: String)
    case successBlue(title: String)
    case error(title: String, subtitle: String?)
    case info(title: String, subtitle: String?)
    
    var title: String {
        switch self {
        case .successGreen(let title),
             .successBlue(let title),
             .error(let title, _),
             .info(let title, _):
            return title
        }
    }
    
    var subtitle: String? {
        switch self {
        case .error(_, let subtitle),
             .info(_, let subtitle):
            return subtitle
        case .successGreen, .successBlue:
            return nil
        }
    }
    
    var icon: Image {
        switch self {
        case .successGreen, .successBlue:
            return Images.Icons.successStoke
        case .error, .info:
            return Images.Icons.infoStoke
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .successGreen:
            return Colors.Green.green400
        case .successBlue:
            return Colors.Blue.blue500
        case .error:
            return Colors.Red.red500
        case .info:
            return Colors.Neutral.grey800
        }
    }
    
    var subtitleColor: Color {
        switch self {
        case .error:
            return Colors.Red.red100
        case .info:
            return Colors.Neutral.grey500
        case .successGreen, .successBlue:
            return .clear
        }
    }
}
