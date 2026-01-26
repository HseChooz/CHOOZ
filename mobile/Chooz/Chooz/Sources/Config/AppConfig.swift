import Foundation

enum AppConfig {
    
    static var apiBaseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["APIBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("APIBaseURL not configured in Info.plist")
        }
        return url
    }
    
    static var googleClientID: String {
        guard let clientID = Bundle.main.infoDictionary?["GIDClientID"] as? String else {
            fatalError("GIDClientID not configured in Info.plist")
        }
        return clientID
    }
}
