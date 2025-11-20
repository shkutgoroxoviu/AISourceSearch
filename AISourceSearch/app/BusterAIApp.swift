//
//  BusterAIApp.swift
//  BusterAI
//
//  Created by b on 05.11.2025.
//
import SwiftUI

@main
struct BusterAIApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isRegistering: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                MainTabView()
            } else {
                OnboardingContainerView()
                    .onAppear {
                        registerAndAuthorizeUser()
                    }
            }
        }
    }
    
    func registerAndAuthorizeUser() {
        isRegistering = true
        let keychain = KeyChainService.shared
        
        var apphudId: String
        if let storedId = keychain.loadKeychain(key: "apphud_id"), !storedId.isEmpty {
            apphudId = storedId
        } else {
            apphudId = UUID().uuidString
            keychain.saveKeychain(value: apphudId, key: "apphud_id")
        }
        
        ReverseSearchAPI.shared.createUser(apphudId: apphudId) { result in
            switch result {
            case .success(let userId):
                keychain.saveKeychain(value: userId, key: "user_id")
                
                ReverseSearchAPI.shared.authorizeUser(userId: userId) { authResult in
                    DispatchQueue.main.async {
                        switch authResult {
                        case .success(let token):
                            keychain.saveKeychain(value: token, key: "access_token")
                            isRegistering = false
                        case .failure(let error):
                            print("Authorization error:", error.localizedDescription)
                            isRegistering = false
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("User creation error:", error.localizedDescription)
                    isRegistering = false
                }
            }
        }
    }
}


