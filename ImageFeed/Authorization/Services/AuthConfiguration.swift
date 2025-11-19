//
//  Constants.swift
//  ImageFeed
//
//  Created by Vladimir on 28.02.2025.
//

import Foundation


enum Constants {
    static let accessKey = "qEjC0CE_szJexm7g2JaWECzrSUrpoXe32le86UJR1vA"
    static let secretKey = "yWxkzZQmpelJn9tzHpnDcRXwk253mICdvFN91cRfU-E"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthURLString = "https://unsplash.com/oauth/authorize"
}


struct AuthConfiguration {
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let defaultBaseURLString: String
    let unsplashAuthURLString: String
    
	init(
		accessKey: String,
		secretKey: String,
		redirectURI: String,
		accessScope: String,
		defaultBaseURL: URL?,
		defaultBaseURLString: String,
		unsplashAuthURLString: String
	) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.defaultBaseURLString = defaultBaseURLString
        self.unsplashAuthURLString = unsplashAuthURLString
    }
    
    static var standard: AuthConfiguration {
		AuthConfiguration(
			accessKey: Constants.accessKey,
			secretKey: Constants.secretKey,
			redirectURI: Constants.redirectURI,
			accessScope: Constants.accessScope,
			defaultBaseURL: Constants.defaultBaseURL,
			defaultBaseURLString: Constants.defaultBaseURLString,
			unsplashAuthURLString: Constants.unsplashAuthURLString
		)
    }
    
}
