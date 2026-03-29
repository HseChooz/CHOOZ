import Foundation
import AppMetricaCore
import AppMetricaCrashes

final class AnalyticsService {
    
    // MARK: - Internal Methods
    
    func track(_ event: AnalyticsEvent) {
        AppMetrica.reportEvent(name: event.name, parameters: event.parameters, onFailure: { error in
            #if DEBUG
            print("[Analytics] Failed to report event '\(event.name)': \(error.localizedDescription)")
            #endif
        })
    }
    
    func trackScreen(_ screen: Screen) {
        track(.screenViewed(screen))
    }
    
    func setUserProfileID(_ profileID: String) {
        AppMetrica.userProfileID = profileID
    }
    
    func reportUserProfile(_ profile: MutableUserProfile) {
        AppMetrica.reportUserProfile(profile, onFailure: { error in
            #if DEBUG
            print("[Analytics] Failed to report user profile: \(error.localizedDescription)")
            #endif
        })
    }
    
    func reportError(_ error: NSError, message: String? = nil) {
        AppMetricaCrashes.crashes().report(nserror: error, onFailure: { reportError in
            #if DEBUG
            print("[Analytics] Failed to report error: \(reportError.localizedDescription)")
            #endif
        })
    }
    
    func sendEventsBuffer() {
        AppMetrica.sendEventsBuffer()
    }
}
