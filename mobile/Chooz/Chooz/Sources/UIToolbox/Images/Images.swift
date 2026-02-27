import SwiftUI

enum Images {
    
    enum Icons {
        static let google = Image("icon_google", bundle: .module)
        static let yandex = Image("icon_yandex", bundle: .module)
        static let flowerShape = Image("icon_flower_shape", bundle: .module)
        static let infoStoke = Image("icon_info_stroke", bundle: .module)
        static let successStoke = Image("icon_success_stroke", bundle: .module)
        static let cross = Image("icon_cross", bundle: .module)
        static let calendar = Image("icon_calendar", bundle: .module)
        static let calendarBlue = Image("icon_calendar_blue", bundle: .module)
        static let profile = Image("icon_profile", bundle: .module)
        static let settings = Image("icon_settings", bundle: .module)
        static let share = Image("icon_share", bundle: .module)
        static let crossLarge = Image("icon_cross_large", bundle: .module)
        static let camera = Image("icon_camera", bundle: .module)
        static let dropdown = Image("icon_dropdown", bundle: .module)
        static let arrowUp = Image("icon_arrow_up", bundle: .module)
        static let trash = Image("icon_trash", bundle: .module)
        static let trashWhite = Image("icon_trash_white", bundle: .module)
        static let repeatIcon = Image("icon_repeat", bundle: .module)
        static let reapetIconPurple = Image("icon_repeat_purple", bundle: .module)
        static let notification = Image("icon_notification", bundle: .module)
        static let notificationBlue = Image("icon_notification_blue", bundle: .module)
        static let edit = Image("icon_edit", bundle: .module)
        static let lock = Image("icon_lock", bundle: .module)
        static let lockRed = Image("icon_lock_red", bundle: .module)
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
        enum Joyful {
            static let v1 = Image("mascotte_joyful_v1", bundle: .module)
        }
        
        enum Curious {
            static let v3 = Image("mascotte_curious_v3", bundle: .module)
        }
        
        enum Shy {
            static let v1 = Image("mascotte_shy_v1", bundle: .module)
        }
    }
    
    static let onboardingWishlistIcon = Image("onboarding_wishlist", bundle: .module)
    
}
