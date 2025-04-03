//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//

import Foundation
import Kingfisher
import UIKit


//MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var observation: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    //MARK: - Private Methods
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        let stubImage = UIImage(resource: .imagesListStub)
        let tableWidth = tableView.frame.size.width
        let imageViewWidth = tableWidth - 32
        let imageViewHeight = imageViewWidth/(stubImage.size.width)*(stubImage.size.height)
        let rowHeight = imageViewHeight + 8
        tableView.rowHeight = rowHeight
    }
    
    private func addObserver() {
        observation = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                guard let userInfo = notification.userInfo as? [String: [Photo]], let newPhotos = userInfo["newPhotos"] else {
                    assertionFailure("ImagesListViewController.addObserver: failed to get newPhotos from notification")
                    return
                }
                self?.updateTableViewAnimated(with: newPhotos)
        }
    }
    
    private func configCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        guard let thumbImageURL = URL(string: photo.thumbImageURL) else {
            assertionFailure("ImagesListViewController.configCell")
            return
        }
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: thumbImageURL, placeholder: UIImage(resource: .imagesListStub))
        if let photoDate = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: photoDate)
        } else {
            cell.dateLabel.text = ""
        }
        cell.likeButton.setImage(photo.isLiked ? UIImage(resource: .favouritesActive) : UIImage(resource: .favouritesNonActive), for: .normal)
    }
    
    private func updateTableViewAnimated(with newPhotos: [Photo]) {
        let newCount = imagesListService.photos.count
        let oldCount = newCount - newPhotos.count
        let range = oldCount..<newCount
        let indexPaths = range.map({ IndexPath(row: $0, section: 0)})
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
}


//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController, let indexPath = sender as? IndexPath else {
                assertionFailure("ImagesListViewController.prepare: Failed to create ViewController or extract indexPath")
                return
            }
            let imageURLString = imagesListService.photos[indexPath.row].largeImageURL
            viewController.imageURL = URL(string: imageURLString)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = imagesListService.photos[indexPath.row].size
        let tableWidth = tableView.contentSize.width
        let imageViewWidth = tableWidth - 32
        let imageViewHeight = imageViewWidth/(size.width)*(size.height)
        let rowHeight = imageViewHeight + 8
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= imagesListService.photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
}


//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            assertionFailure("ImagesListViewController.tableView: Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }
        configCell(cell, at: indexPath)
        cell.delegate = self
        return cell
    }
    
}


// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure("ImagesListViewController.imagesListCellDidTapLike: Failed to fined index of (dis)liked cell")
            return
        }
        // blocking UI
        // only blocking the button (why block whole screen?)
        cell.likeButton.isEnabled = false
        let photo = imagesListService.photos[indexPath.row]
        let isLike = !photo.isLiked
        imagesListService.changeLike(atIndex: indexPath.row, isLike: isLike) { [weak cell] result in
            cell?.likeButton.isEnabled = true
            switch result {
            case .success:
                cell?.setIsLiked(isLike)
            case .failure:
                // TODO: implement failure
                break
            }
        }
    }
    
}
