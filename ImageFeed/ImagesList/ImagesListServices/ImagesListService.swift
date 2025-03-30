//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Vladimir on 29.03.2025.
//

import Foundation


final class ImagesListService {
    
    // MARK: - Internal Properties
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    
    // MARK: - Private Properties
    
    private var photosSet: Set<Photo> = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private let pathString = "/photos"
    private let itemsPerPage = 10
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    // MARK: - Initializers
    
    private init() { }
    
    // MARK: - Internal Methods
    
    func fetchPhotosNextPage() {
        //TODO: implement fetching photos
        let nextPageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = urlRequest(page: nextPageNumber) else { return }
        if task != nil {
            print("ImagesListService.fetchPhotosNextPage: duplicating request for photos")
            return
        }
        // just in case
        task?.cancel()
        task = urlSession.objectTask(for: request, convertFromSnakeCase: true) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map({ Photo(photoResult: $0) })
                var trueNewPhotos: [Photo] = []
                for newPhoto in newPhotos {
                    if !photosSet.contains(newPhoto) {
                        photosSet.insert(newPhoto)
                        trueNewPhotos.append(newPhoto)
                    }
                }
                photos.append(contentsOf: trueNewPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self, userInfo: ["newPhotos": trueNewPhotos])
                self.lastLoadedPage = nextPageNumber
                self.task = nil
            case .failure:
                print("ImagesListService.fetchPhotosNextPage error")
            }
        }
        task?.resume()
        
    }
    
    //MARK: - Private Methods
    
    private func urlRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.defaultBaseURLString) else {
            assertionFailure("ImagesListService.urlRequest: Failed to create url components from base url string for unsplash")
            return nil
        }
        guard let token = tokenStorage.token else {
            assertionFailure("ImagesListService.urlRequest: Failed to get token from storage")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per_page", value: itemsPerPage.description)
        ]
        urlComponents.path = pathString
        guard let assembledURL = urlComponents.url else {
            assertionFailure("ImagesListService.urlRequest: Failed to create url with filled in query items")
            return nil
        }
        var urlRequest = URLRequest(url: assembledURL)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
