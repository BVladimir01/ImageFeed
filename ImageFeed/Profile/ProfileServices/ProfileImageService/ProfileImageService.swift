//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//

import UIKit


final class ProfileImageService: Fetcher<String, String> {
    
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
    
    override private init() { }
    
    // MARK: - Internal Methods
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = checkConditionsAndReturnRequest(
            newValue: username,
            latestValue: latestUsername,
            task: task,
            request: urlRequest(username: username),
            completion: completion) else { return }
        latestUsername = username
        task?.cancel()
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            defer {
                self?.task = nil
                self?.latestUsername = nil
            }
            guard let self else { return }
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.large
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": avatarURL])
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
            assertionFailure("ProfileImageService: Failed to create url for profile request")
            return nil
        }
        guard let token = tokenStorage.token else {
            assertionFailure("ProfileImageService: Failed to load token for avatar url request")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
