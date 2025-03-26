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
final class OAuth2Service {
    
    //MARK: - Internal Properties
    
    static let shared = OAuth2Service()
    
    //MARK: - Private Properties
    
    private let baseUrlAuthString = "https://unsplash.com/oauth/token"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask? = nil
    private var latestCode: String? = nil
    
    //MARK: - Initializers
    
    private init() { }
    
    //MARK: - Internal Methods
    
    func fetchOAuthToken(from code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard Thread.isMainThread else {
            assertionFailure("OAuth2Service: trying to fetch token from secondary thread")
            completion(.failure(AuthServiceError.wrongThread))
            return
        }
        guard let request = assembleURLRequest(from: code) else {
            assertionFailure("OAuth2Service: Failed to create request for token fetching")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        guard code != latestCode else {
            print("OAuth2Service: duplicating request for token")
            completion(.failure(AuthServiceError.duplicateRequest))
            return
        }
        latestCode = code
        task?.cancel()
        let task = urlSession.objectTask(for: request) { [weak self](result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.task = nil
                self?.latestCode = nil
            }
            switch result {
            case .success(let resposeBody):
                completion(.success(resposeBody.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Private Methods
    
    private func assembleURLRequest(from code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseUrlAuthString) else {
            assertionFailure("OAuth2Service: Failed to create url for user authorization (post request)")
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
            assertionFailure("OAuth2Service: Failed to create url from urlComponents for user authorization (post request)")
            return nil
        }
        return URLRequest(url: url)
    }
    
}
