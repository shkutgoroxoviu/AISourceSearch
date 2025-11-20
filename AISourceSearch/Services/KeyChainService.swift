//
//  KeyChainService.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import Security
import Foundation

class KeyChainService {
    static let shared = KeyChainService()
    func saveKeychain(value: String, key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    func loadKeychain(key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
