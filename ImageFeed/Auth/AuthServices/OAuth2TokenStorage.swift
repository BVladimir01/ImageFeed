//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import SwiftKeychainWrapper


final class OAuth2TokenStorage {
    
    //MARK: - Internal Properties
    
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get {
            storage.string(forKey: tokenKey)
        }
        set {
            if let unwrappedToken = newValue {
                storage.set(unwrappedToken, forKey: tokenKey)
            } else {
                // maybe better to remove if setting with nil
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
    
    //MARK: - Private Properties
    
    private let tokenKey = "tokenKey"
    private let storage = KeychainWrapper.standard
    
    //MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    
    func removeToken() {
        storage.removeObject(forKey: tokenKey)
    }
    
}
