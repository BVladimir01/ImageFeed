//
//  ProfileImageServiceModels.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//


// MARK: - UserResult
struct UserResult: Codable {
    
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}


// MARK: - ProfileImageServiceError
enum ProfileImageServiceError: Error {
    case invalidRequest
    case wrongThread
    case duplicateRequest
}
