//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Vladimir on 25.03.2025.
//

import UIKit


final class ProfileService {
    
    // MARK: - Internal Properties
    static let shared = ProfileService()
    private(set) var profile: Profile? = nil
    
    // MARK: - Private Properties
    
    private let pathString = "/me"
    private let urlSession = URLSession.shared
    private var task: URLSessionDataTask? = nil
    private var latestToken: String?
    
    // MARK: - Initializers
    
    private init () { }
    
    // MARK: - Internal Methods
    
    func fetchProfile(for token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard Thread.isMainThread else {
            assertionFailure("Trying to fetch profile from secondary thread")
            completion(.failure(ProfileServiceError.wrongThread))
            return
        }
        guard token != latestToken else {
            completion(.failure(ProfileServiceError.duplicateRequest))
            return
        }
        guard let request = urlRequest(for: token) else {
            assertionFailure("Failed to create request for fetching profile")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        latestToken = token
        task?.cancel()
        let task = urlSession.data(for: request) { [weak self] result in
            defer {
                self?.task = nil
                self?.latestToken = nil
            }
            switch result {
            case .success(let data):
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(profileResult: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func urlRequest(for token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defatultBaseURLString + pathString) else {
            assertionFailure("Failed to create url for profile request")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
}
