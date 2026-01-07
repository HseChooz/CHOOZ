import SwiftUI

enum Images {
    
    enum Icons {
        
        static let apple = Image("icon_apple", bundle: .module)
        static let google = Image("icon_google", bundle: .module)
        static let yandex = Image("icon_yandex", bundle: .module)
        
    }
    
    enum Logo {
        
        enum Full {
            
            static let v1 = Image("full_logo_v1", bundle: .module)
            static let v3 = Image("full_logo_v3", bundle: .module)
            
        }
        
    }
    
}
