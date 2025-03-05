//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import Foundation


final class OAuth2Service {
    
    private let baseUrlAuthString = "https://unsplash.com/oauth/token"
    
    private init() {
    }
    
    static let shared = OAuth2Service()
    
    func fetchOAuthToken(from code: String) {
        guard let request = assembleURLRequest(from: code) else { return }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        }
    }
    
    private func assembleURLRequest(from code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseUrlAuthString) else {
            assertionFailure("Failed to create url for user authorization (post request)")
            return nil
        }
        urlComponents.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "client_secret", value: Constants.secretKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            assertionFailure("Failed to create url from urlComponents for user authorization (post request)")
            return nil
        }
        return URLRequest(url: url)
    }
}
