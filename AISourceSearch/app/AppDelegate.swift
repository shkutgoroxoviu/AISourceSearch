//
//  AppDelegate.swift
//  AISourceSearch
//
//  Created by b on 19.11.2025.
//

import UIKit
import ApphudSDK
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        Apphud.start(apiKey: "app_kiuRNi9rcQpztPwTaD7Qx2ehCm1qBb")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        requestIDFAPermission()

        return true
    }

    private func requestIDFAPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                        print("IDFA access granted:", ASIdentifierManager.shared().advertisingIdentifier)
                    case .denied:
                        print("IDFA denied")
                    case .notDetermined:
                        print("IDFA not determined")
                    case .restricted:
                        print("IDFA restricted")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}
