//
//  Models.swift
//  ImageFeed
//
//  Created by Vladimir on 25.03.2025.
//

// MARK: - ProfileResult
struct ProfileResult: Codable {
    
    // MARK: - Internal Properties
    
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case username, bio
    }
    
}


// MARK: - Profile
struct Profile {
    
    // MARK: - Internal Properties
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    // MARK: - Initializers
    
    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
    
    init(profileResult: ProfileResult) {
        username = profileResult.username
        name = profileResult.firstName + (profileResult.lastName ?? "")
        loginName = "@" + username
        bio = profileResult.bio ?? ""
    }
    
}


// MARK: - ProfileServiceError
enum ProfileServiceError: Error {
    case invalidRequest
    case wrongThread
    case duplicateRequest
}
