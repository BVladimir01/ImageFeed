//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 16.04.2025.
//

import Foundation


// MARK: - ImagesListPresenterProtocol
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var feedLength: Int { get }
    
    func viewDidLoad()
    func cellViewModel(for index: Int) -> CellViewModel
    func imageSize(at index: Int) -> CGSize
    func likeButtonTapped(cell: ImagesListCell, index: Int)
    func cellTapped(at index: Int)
    func didScrollToBottom()
}


// MARK: - ImagesListPresenter
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Internal Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var feedLength: Int {
        photos.count
    }
    
    // MARK: - Private Properties
    
    private var observation: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    private var photos: [Photo] {
        imagesListService.photos
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        addObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    func cellViewModel(for index: Int) -> CellViewModel {
        let photo = photos[index]
        let imageURL = URL(string: photo.thumbImageURL)
        let dateString: String
        if let photoDate = photo.createdAt {
            dateString = dateFormatter.string(from: photoDate)
        } else {
            dateString = ""
        }
        return CellViewModel(imageURL: imageURL, dateString: dateString, isLiked: photo.isLiked)
    }
    
    func imageSize(at index: Int) -> CGSize {
        photos[index].size
    }
    
    func likeButtonTapped(cell: ImagesListCell, index: Int) {
        view?.setProgressHUDActive(true)
        view?.setLikeButton(at: cell, active: false)
        let photo = photos[index]
        let isLike = !photo.isLiked
        imagesListService.changeLike(atIndex: index, isLike: isLike) { [weak self] result in
            switch result {
            case .success:
                self?.view?.setCellLiked(cell: cell, liked: isLike)
                self?.view?.setLikeButton(at: cell, active: true)
                self?.view?.setProgressHUDActive(false)
            case .failure:
                self?.view?.setLikeButton(at: cell, active: true)
                self?.view?.setProgressHUDActive(false)
                self?.view?.showLikeErrorAlert()
            }
        }
    }
    
    func cellTapped(at index: Int) {
        let imageURL = URL(string: photos[index].largeImageURL)
        view?.showSingleImageViewController(imageURL: imageURL)
    }
    
    func didScrollToBottom() {
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Private Methods
    
    private func addObserver() {
        observation = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                guard let userInfo = notification.userInfo as? [String: [Photo]], let newPhotos = userInfo["newPhotos"] else {
                    assertionFailure("ImagesListViewController.addObserver: failed to get newPhotos from notification")
                    return
                }
                guard let self else { return }
                let newCount = self.photos.count
                let oldCount = newCount - newPhotos.count
                let range = oldCount..<newCount
                let indexPaths = range.map({ IndexPath(row: $0, section: 0)})
                self.view?.updateTableViewAnimated(at: indexPaths)
        }
    }
}


