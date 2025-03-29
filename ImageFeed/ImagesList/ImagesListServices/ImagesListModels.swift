//
//  ImagesListModels.swift
//  ImageFeed
//
//  Created by Vladimir on 29.03.2025.
//

import Foundation


struct Photo {
    
    static let dateFormatter = ISO8601DateFormatter()
    
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}


struct PhotoResult: Decodable {
    
    let id: String
    let createdAt: String
    let width: Double
    let height: Double
    let description: String?
    let likedByUser: Bool
    let urls: URLResult
    
    struct URLResult: Decodable {
        let raw: String
        let full: String
        let regular: String
        let thumb: String
    }
    
}


extension Photo {
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        createdAt = Self.dateFormatter.date(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        let urlResult = photoResult.urls
        thumbImageURL = urlResult.thumb
        largeImageURL = urlResult.full
        isLiked = photoResult.likedByUser
    }
}
