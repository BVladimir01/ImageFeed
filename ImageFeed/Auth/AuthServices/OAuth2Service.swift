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
        assert(Thread.isMainThread, "Calling from secondary thread")
        guard let request = assembleURLRequest(from: code) else {
            assertionFailure("Failed to create request for token fetching")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        guard code != latestCode else {
            completion(.failure(AuthServiceError.duplicateRequest))
            return
        }
        latestCode = code
        task?.cancel()
        let jsonDecoder = JSONDecoder()
        let task = urlSession.data(for: request) { [weak self] result in
            defer {
                self?.task = nil
                self?.latestCode = nil
            }
            switch result {
            case .success(let data):
                do {
                    let responseBody = try jsonDecoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessToken))
                } catch {
                    assertionFailure("Failed to decode token")
                    completion(.failure(error))
                }
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
