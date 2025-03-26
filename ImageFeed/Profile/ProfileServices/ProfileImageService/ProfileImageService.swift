//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//

import UIKit


final class ProfileImageService {
    
    // MARK: - Internal Properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    
    // MARK: - Private Properties
    
    private let pathString = "/users/"
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var latestUsername: String?
    private var task: URLSessionTask?
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard Thread.isMainThread else {
            assertionFailure("Trying to fetch profile from secondary thread")
            completion(.failure(ProfileImageServiceError.wrongThread))
            return
        }
        guard username != latestUsername else {
            completion(.failure(ProfileImageServiceError.duplicateRequest))
            return
        }
        guard let request = urlRequest(username: username) else {
            assertionFailure("Failed to create request for fetching avatar url")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        latestUsername = username
        task?.cancel()
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            defer {
                self?.task = nil
                self?.latestUsername = nil
            }
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self?.avatarURL = avatarURL
                completion(.success(avatarURL))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func urlRequest(username: String) -> URLRequest? {
        guard let url = URL(string: Constants.defatultBaseURLString + pathString + username) else {
            assertionFailure("Failed to create url for profile request")
            return nil
        }
        guard let token = tokenStorage.token else {
            assertionFailure("Failed to load token for avatar url request")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
