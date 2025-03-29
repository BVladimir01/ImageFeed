//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import Foundation


// MARK: - AuthServiceError
enum AuthServiceError: Error {
    case duplicateRequest
    case invalidRequest
    case wrongThread
}


// MARK: - OAuth2Service
final class OAuth2Service: Fetcher<String, String> {
    
    //MARK: - Internal Properties
    
    static let shared = OAuth2Service()
    
    //MARK: - Private Properties
    
    private let baseUrlAuthString = "https://unsplash.com/oauth/token"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask? = nil
    private var latestCode: String? = nil
    
    //MARK: - Initializers
    
    override private init() { }
    
    //MARK: - Internal Methods
    
    func fetchOAuthToken(from code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = checkConditionsAndReturnRequest(
            newValue: code,
            latestValue: latestCode,
            task: task,
            request: assembleURLRequest(from: code),
            completion: completion) else { return }
        latestCode = code
        task?.cancel()
        let task = urlSession.objectTask(for: request) { [weak self](result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.task = nil
                self?.latestCode = nil
            }
            switch result {
            case .success(let responseBody):
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                // other error details are printed in URLSession extension methods
                print("OAuth2Service.fetchOAuthToken error")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Private Methods
    
    private func assembleURLRequest(from code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseUrlAuthString) else {
            assertionFailure("OAuth2Service.assembleURLRequest: Failed to create url for user authorization (post request)")
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
            assertionFailure("OAuth2Service.assembleURLRequest: Failed to create url from urlComponents for user authorization (post request)")
            return nil
        }
        return URLRequest(url: url)
    }
    
}
