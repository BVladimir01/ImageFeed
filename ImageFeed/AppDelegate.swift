//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//

import ProgressHUD
import UIKit
import WebKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if CommandLine.arguments.contains("--uitest-reset-token") { removeTokenAndClearCookies() }
        UIBlockingHUD.setupProgressHUD()
        return true
    }
    
    private func removeTokenAndClearCookies() {
        OAuth2TokenStorage.shared.removeToken()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: { })
            }
        }
    }

}

