//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Vladimir on 25.03.2025.
//

import UIKit


final class ProfileService: Fetcher<String, Profile> {
    
    // MARK: - Internal Properties
    static let shared = ProfileService()
    private(set) var profile: Profile? = nil
    
    // MARK: - Private Properties
    
    private let pathString = "/me"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask? = nil
    private var latestToken: String?
    
    // MARK: - Initializers
    
    override private init () { }
    
    // MARK: - Internal Methods
    
    func fetchProfile(for token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = checkConditionsAndReturnRequest(
            newValue: token,
            latestValue: latestToken,
            task: task,
            request: urlRequest(for: token),
            completion: completion) else { return }
        latestToken = token
        task?.cancel()
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            defer {
                self?.task = nil
                self?.latestToken = nil
            }
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                // other error details are printed in URLSession extension methods
                print("ProfileImageService.fetchProfile error")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func urlRequest(for token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURLString + pathString) else {
            assertionFailure("ProfileService.urlRequest: Failed to create url for profile request")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
    
}
