//
//  ImagesListModels.swift
//  ImageFeed
//
//  Created by Vladimir on 29.03.2025.
//

import Foundation


struct Photo: Hashable {
    
    static let dateFormatter = ISO8601DateFormatter()
    
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
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
        let small: String
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
        thumbImageURL = urlResult.small
        largeImageURL = urlResult.raw
        isLiked = photoResult.likedByUser
    }
}
