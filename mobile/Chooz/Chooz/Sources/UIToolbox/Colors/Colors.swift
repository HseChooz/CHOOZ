import SwiftUI

enum Colors {
    
    enum Common {
        static let white = Color.white
        static let black = Color.black
    }
    
    enum Neutral {
        static let grey100 = Color("grey100", bundle: .module)
        static let grey200 = Color("grey200", bundle: .module)
        static let grey400 = Color("grey400", bundle: .module)
        static let grey500 = Color("grey500", bundle: .module)
        static let grey600 = Color("grey600", bundle: .module)
        static let grey700 = Color("grey700", bundle: .module)
        static let grey800 = Color("grey800", bundle: .module)
        static let grey900 = Color("grey900", bundle: .module)
        static let grey5b = Color("grey5b", bundle: .module)
    }
    
    enum Blue {
        static let blue100 = Color("blue100", bundle: .module)
        static let blue300 = Color("blue300", bundle: .module)
        static let blue500 = Color("blue500", bundle: .module)
    }
    
    enum Green {
        static let green400 = Color("green400", bundle: .module)
    }
    
    enum Red {
        static let red100 = Color("red100", bundle: .module)
        static let red500 = Color("red500", bundle: .module)
    }
    
    enum RedOrange {
        static let redOrange400 = Color("red_orange400", bundle: .module)
    }
    
}
