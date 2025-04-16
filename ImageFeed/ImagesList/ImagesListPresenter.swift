//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 16.04.2025.
//

import Foundation


protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    private var observation: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    
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
                let newCount = self.imagesListService.photos.count
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
    
}


