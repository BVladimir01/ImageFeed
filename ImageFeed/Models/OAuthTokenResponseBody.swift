//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

struct OAuthTokenResponseBody: Decodable {
    
    var accessToken: String
    var scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
    }
    
}
