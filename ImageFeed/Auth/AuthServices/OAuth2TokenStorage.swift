//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import Foundation


final class OAuth2TokenStorage {
    
    //MARK: - Internal Properties
    
    static let shared = OAuth2TokenStorage()
    var token: String? {
        get {
            storage.string(forKey: tokenKey)
        }
        set {
            storage.set(newValue, forKey: tokenKey)
        }
    }
    
    //MARK: - Private Properties
    
    private let tokenKey = "tokenKey"
    private let storage = UserDefaults.standard
    
    //MARK: - Initializers
    
    private init() { }
    
}
