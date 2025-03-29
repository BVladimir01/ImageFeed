//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Vladimir on 29.03.2025.
//

import Foundation

final class ImagesListService {
    
    private(set) var photos: [Photo] = []
    
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    
    func fetchPhotosNextPage() {
        //TODO: implement fetching photos
    }
}
