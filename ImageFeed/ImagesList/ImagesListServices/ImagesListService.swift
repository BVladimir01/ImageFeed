//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Vladimir on 29.03.2025.
//

import Foundation


// MARK: - ImagesListServiceProtocol
protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(atIndex alteringPhotoIndex: Int, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func cleanUpService()
}

final class ImagesListService: ImagesListServiceProtocol {
    
    // MARK: - Internal Properties
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    // MARK: - Private Properties
    
    private var photosSet: Set<Photo> = []
    private var fetchPhotosTask: URLSessionTask?
    private var lastLoadedPage: Int = 0
    private var changeLikeTask: URLSessionTask?
    
    private let photoRequestPathString = "/photos"
    private let likePhotoRequestPathString = "/like"
    private let itemsPerPage = 10
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    // MARK: - Internal Methods
    
    func fetchPhotosNextPage() {
        let nextPageNumber = lastLoadedPage + 1
        guard let request = assembleURLRequestForPhotos(page: nextPageNumber) else { return }
        if fetchPhotosTask != nil {
            print("ImagesListService.fetchPhotosNextPage: duplicating request for photos")
            return
        }
        // just in case
        fetchPhotosTask?.cancel()
        fetchPhotosTask = urlSession.objectTask(for: request, convertFromSnakeCase: true) { [weak self] (result: Result<[PhotoResult], Error>) in
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
                self.fetchPhotosTask = nil
            case .failure:
                print("ImagesListService.fetchPhotosNextPage error")
                self.fetchPhotosTask = nil
            }
        }
        fetchPhotosTask?.resume()
    }
    
    func changeLike(atIndex alteringPhotoIndex: Int, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let alteringPhotoID = photos[alteringPhotoIndex].id
        guard let request = assembleURLRequestForLikeChange(photoID: alteringPhotoID, isLike: isLike) else { return }
        if changeLikeTask != nil {
            print("ImagesListService.changeLike: duplicating request for changing like for photo \(alteringPhotoID)")
            return
        }
        changeLikeTask?.cancel()
        changeLikeTask = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                let alteringPhoto = self.photos[alteringPhotoIndex]
                let alteredPhoto = Photo(id: alteringPhoto.id, 
                                         size: alteringPhoto.size,
                                         createdAt: alteringPhoto.createdAt,
                                         welcomeDescription: alteringPhoto.welcomeDescription,
                                         thumbImageURL: alteringPhoto.thumbImageURL,
                                         largeImageURL: alteringPhoto.largeImageURL,
                                         isLiked: isLike)
                self.photos[alteringPhotoIndex] = alteredPhoto
                self.changeLikeTask = nil
                completion(.success(()))
            case .failure(let error):
                print("ImagesListService.changeLike error")
                self.changeLikeTask = nil
                completion(.failure(error))
            }
        }
        changeLikeTask?.resume()
    }
    
    func cleanUpService() {
        photos = []
        photosSet = []
        fetchPhotosTask?.cancel()
        fetchPhotosTask = nil
        changeLikeTask?.cancel()
        changeLikeTask = nil
        lastLoadedPage = 0
    }
    
    //MARK: - Private Methods
    
    private func assembleURLRequestForPhotos(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.defaultBaseURLString) else {
            assertionFailure("ImagesListService.assembleURLRequestForPhotos: Failed to create url components from base url string for unsplash")
            return nil
        }
        guard let token = tokenStorage.token else {
            assertionFailure("ImagesListService.assembleURLRequestForPhotos: Failed to get token from storage")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "per_page", value: itemsPerPage.description)
        ]
        urlComponents.path = photoRequestPathString
        guard let assembledURL = urlComponents.url else {
            assertionFailure("ImagesListService.assembleURLRequestForPhotos: Failed to create url with filled in query items")
            return nil
        }
        var urlRequest = URLRequest(url: assembledURL)
        urlRequest.httpMethod = HTTPMethod.get
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    private func assembleURLRequestForLikeChange(photoID: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURLString + photoRequestPathString + "/\(photoID)" + likePhotoRequestPathString) else {
            assertionFailure("ImagesListService.assembleURLRequestForLikeChange: Failed to create url")
            return nil
        }
        guard let token = tokenStorage.token else {
            assertionFailure("ImagesListService.assembleURLRequestForLikeChange: Failed to get token from storage")
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = isLike ? HTTPMethod.post : HTTPMethod.delete
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
}
