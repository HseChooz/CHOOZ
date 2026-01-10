import SwiftUI

enum Colors {
    
    enum Common {
        static let white = Color.white
        static let black = Color.black
    }
    
    enum Neutral {
        static let grey200 = Color("grey200", bundle: .module)
        static let grey400 = Color("grey400", bundle: .module)
        static let grey600 = Color("grey600", bundle: .module)
        static let grey800 = Color("grey800", bundle: .module)
        static let grey900 = Color("grey900", bundle: .module)
    }
    
    enum Blue {
        static let blue300 = Color("blue300", bundle: .module)
        static let blue500 = Color("blue500", bundle: .module)
    }
    
    enum RedOrange {
        static let redOrange400 = Color("red_orange400", bundle: .module)
    }
    
}
