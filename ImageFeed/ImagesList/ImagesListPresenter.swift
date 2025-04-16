//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 16.04.2025.
//

import Foundation


protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func cellViewModel(at index: Int) -> CellViewModel 
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] {
        imagesListService.photos
    }
    
    private var observation: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
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
    
    func viewDidLoad() {
        addObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    func cellViewModel(at index: Int) -> CellViewModel {
        let photo = photos[index]
        let imageURL = URL(string: photo.thumbImageURL)
        let dateString: String
        if let photoDate = photo.createdAt {
            dateString = dateFormatter.string(from: photoDate)
        } else {
            dateString = ""
        }
        return CellViewModel(imageURL: imageURL,
                             dateString: dateString,
                             isLiked: photo.isLiked)
    }
    
}


