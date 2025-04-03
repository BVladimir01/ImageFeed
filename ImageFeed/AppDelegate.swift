//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//

import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupProgressHUD()
        return true
    }
    
    private func setupProgressHUD() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .black.withAlphaComponent(0.5)
        ProgressHUD.colorAnimation = .lightGray
    }

}

