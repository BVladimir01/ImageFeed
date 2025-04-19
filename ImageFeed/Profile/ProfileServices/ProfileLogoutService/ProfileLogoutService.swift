//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Vladimir on 31.03.2025.
//

import Foundation
import WebKit


// MARK: - ProfileLogoutServiceProtocol
protocol ProfileLogoutServiceProtocol: AnyObject {
    var delegate: ProfileLogoutServiceDelegate? { get set }
    func logout()
}


// MARK: - ProfileLogoutService
final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    
    // MARK: - Internal Properties
    
    weak var delegate: ProfileLogoutServiceDelegate? = nil
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Internal Methods
    func logout() {
        cleanCookies()
        cleanServices()
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
        oAuth2Service.cleanUpService()
        tokenStorage.removeToken()
    }
    
}


// MARK: - ProfileLogoutServiceDelegate
protocol ProfileLogoutServiceDelegate: AnyObject {
    func logoutServiceDidFinishCleanUp()
}
