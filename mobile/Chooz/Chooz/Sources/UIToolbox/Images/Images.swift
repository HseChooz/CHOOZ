import SwiftUI

enum Images {
    
    enum Icons {
        static let apple = Image("icon_apple", bundle: .module)
        static let google = Image("icon_google", bundle: .module)
        static let yandex = Image("icon_yandex", bundle: .module)
        static let flowerShape = Image("icon_flower_shape", bundle: .module)
        static let infoStoke = Image("icon_info_stroke", bundle: .module)
        static let successStoke = Image("icon_success_stroke", bundle: .module)
        static let cross = Image("icon_cross", bundle: .module)
    }
    
    enum Logo {
        enum Full {
            static let v1 = Image("full_logo_v1", bundle: .module)
            static let v3 = Image("full_logo_v3", bundle: .module)
        }
        
        enum Short {
            static let v3 = Image("short_logo_v3", bundle: .module)
        }
    }
    
    enum Mascotte {
        enum Curious {
            static let v3 = Image("mascotte_curious_v3", bundle: .module)
        }
        
        enum Shy {
            static let v1 = Image("mascotte_shy_v1", bundle: .module)
        }
    }
    
    static let onboardingWishlistIcon = Image("onboarding_wishlist", bundle: .module)
    
}
