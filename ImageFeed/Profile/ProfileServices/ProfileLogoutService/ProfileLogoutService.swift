//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Vladimir on 31.03.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let imagesListService = ImagesListService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let oAuth2Service = OAuth2Service.shared
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanServices()
        cleanTokens()
        switchToSplashScreen()
    }
    
    private func switchToSplashScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("ProfileLogoutService.switchToSplashScreen: Failed to get windowScene or its window when switching to splashscreen on logout")
            return
        }
        let splashScreen = SplashViewController()
        window.rootViewController = splashScreen
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: { })
            }
        }
    }
    
    private func cleanServices() {
        imagesListService.cleanUpService()
        profileImageService.cleanUpService()
        profileService.cleanUpService()
        oAuth2Service.cleanUpService()
    }
    
    private func cleanTokens() {
        tokenStorage.removeToken()
    }
    
}
