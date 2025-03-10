//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let tokenKey = "tokenKey"
    private let storage = UserDefaults.standard
    
    var token: String? {
        get {
            storage.string(forKey: tokenKey)
        }
        set {
            storage.set(newValue, forKey: tokenKey)
        }
    }
    
    private init() { }
    
    static let shared = OAuth2TokenStorage()
}
