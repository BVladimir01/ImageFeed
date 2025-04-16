//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//

import Foundation
import Kingfisher
import ProgressHUD
import UIKit


// MARK: - ImagesListViewControllerProtocol
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(at indexPaths: [IndexPath])
    func configCell(_ cell: ImagesListCell, at indexPath: IndexPath, with viewModel: CellViewModel)
    func injectPresenter(_ presenter: ImagesListPresenterProtocol)
    func setProgressHUDActive(_ isActive: Bool)
    func setLikeButton(at cell: ImagesListCell, active: Bool)
    func setCellLiked(cell: ImagesListCell, liked: Bool)
    func showLikeErrorAlert()
}

extension ImagesListViewControllerProtocol {
    func injectPresenter(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}


//MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - Internal Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    //MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var observation: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    private let alertPresenter = SimpleAlertPresenter()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        alertPresenter.delegate = self
        presenter?.viewDidLoad()
    }
    
    // MARK: - Internal Methods
    
    func showLikeErrorAlert() {
        let alertModel = SimpleAlertModel(title: "Что-то пошло не так(",
                                          message: "Не удалось выполнить действие",
                                          buttonText: "ОК")
        alertPresenter.presentAlert(alertModel)
    }
    
    func setProgressHUDActive(_ isActive: Bool) {
        if isActive {
            ProgressHUD.animate()
        } else {
            ProgressHUD.dismiss()
        }
    }
    
    func setLikeButton(at cell: ImagesListCell, active: Bool) {
        cell.likeButton.isEnabled = active
    }
    
    func setCellLiked(cell: ImagesListCell, liked: Bool) {
        cell.setIsLiked(liked)
    }
    
    func configCell(_ cell: ImagesListCell, at indexPath: IndexPath, with viewModel: CellViewModel) {
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(with: viewModel.imageURL, placeholder: UIImage(resource: .imagesListStub))
        cell.dateLabel.text = viewModel.dateString
        cell.likeButton.setImage(viewModel.isLiked ? UIImage(resource: .favouritesActive) : UIImage(resource: .favouritesNonActive), for: .normal)
    }
    
    func updateTableViewAnimated(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    //MARK: - Private Methods
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = TableViewConstants.contentInset
        let stubImage = UIImage(resource: .imagesListStub)
        let tableWidth = tableView.frame.size.width
        let imageViewWidth = tableWidth - TableViewConstants.cellLateralHalfSpacing*2
        let imageViewHeight = imageViewWidth/(stubImage.size.width)*(stubImage.size.height)
        let rowHeight = imageViewHeight + TableViewConstants.cellVerticalHalfSpacing*2
        tableView.rowHeight = rowHeight
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
        let imageViewWidth = tableWidth - TableViewConstants.cellLateralHalfSpacing*2
        let imageViewHeight = imageViewWidth/(size.width)*(size.height)
        let rowHeight = imageViewHeight + TableViewConstants.cellVerticalHalfSpacing*2
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
        guard let photos = presenter?.photos else {
            assertionFailure("ImagesListViewController.tableView: presenter is nil")
            return 0
        }
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            assertionFailure("ImagesListViewController.tableView: Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }
        guard let presenter else {
            assertionFailure("ImagesListViewController.tableView: presenter is nil")
            return UITableViewCell()
        }
        let cellViewModel = presenter.cellViewModel(for: indexPath.row)
        configCell(cell, at: indexPath, with: cellViewModel)
        cell.delegate = self
        return cell
    }
    
}


// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure("ImagesListViewController.imagesListCellDidTapLike error: failed to find index of cell")
            return
        }
        presenter?.likeButtonTapped(cell: cell, index: indexPath.row)
    }
    
}


extension ImagesListViewController {
    private struct TableViewConstants {
        private init() { }
        static let contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        static let cellLateralHalfSpacing: CGFloat = 16
        static let cellVerticalHalfSpacing: CGFloat  = 4
    }
}
