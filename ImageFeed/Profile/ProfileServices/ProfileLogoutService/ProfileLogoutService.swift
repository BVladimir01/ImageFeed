//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Vladimir on 31.03.2025.
//

import Foundation
import WebKit


final class ProfileLogoutService {
    
    // MARK: - Internal Properties
    
    static let shared = ProfileLogoutService()
    weak var delegate: ProfileLogoutServiceDelegate? = nil
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let imagesListService = ImagesListService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    func logout() {
        cleanCookies()
        cleanServices()
        cleanTokens()
        delegate?.logoutServiceDidFinishCleanUp()
    }
    
    // MARK: - Private Methods
    
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
