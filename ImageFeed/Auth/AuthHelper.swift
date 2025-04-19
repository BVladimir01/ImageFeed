//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Vladimir on 14.04.2025.
//

import Foundation


// MARK: - AuthHelperProtocol
protocol AuthHelperProtocol {
    func createAuthRequest() -> URLRequest?
    func getCode(from url: URL) -> String?
}


// MARK: - AuthHelper
final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Private Properties
    
    private let configuration: AuthConfiguration
    
    // MARK: - Initializers
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Internal Methods
    
    func createAuthRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func getCode(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code"} )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.unsplashAuthURLString) else {
            assertionFailure("AuthHelper.authURL: Failed to create URLComponents for authorization")
            return nil
        }
        urlComponents.queryItems = [
            .init(name: "client_id", value: configuration.accessKey),
            .init(name: "redirect_uri", value: configuration.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents.url
    }
    
}
