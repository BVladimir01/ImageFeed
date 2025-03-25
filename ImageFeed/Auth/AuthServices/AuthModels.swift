//
//  Models.swift
//  ImageFeed
//
//  Created by Vladimir on 25.03.2025.
//

//MARK: - OAuthTokenResponseBody
struct OAuthTokenResponseBody: Decodable {
    
    var accessToken: String
    var scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
    }
    
}
