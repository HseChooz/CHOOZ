import Foundation
import Security

final class TokenStorage {
    
    // MARK: - Internal Properties
    
    var accessToken: String? {
        get { read(key: "accessToken") }
        set { save(key: "accessToken", value: newValue) }
    }
    
    var refreshToken: String? {
        get { read(key: "refreshToken") }
        set { save(key: "refreshToken", value: newValue) }
    }
    
    var isLoggedIn: Bool {
        accessToken != nil
    }
    
    // MARK: - Internal Methods
    
    func clear() {
        accessToken = nil
        refreshToken = nil
    }
    
    // MARK: - Private Properties
    
    private let service = "com.auth.chooz".data(using: .utf8)!
    
    // MARK: - Private Methods
    
    private func save(key: String, value: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
        
        guard
            let value,
            let data = value.data(using: .utf8)
        else {
            return
        }
        
        var newQuery = query
        newQuery[kSecValueData as String] = data
        SecItemAdd(newQuery as CFDictionary, nil)
    }
    
    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard
            status == errSecSuccess,
            let data = result as? Data
        else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
