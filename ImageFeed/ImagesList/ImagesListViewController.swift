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
    
    func injectPresenter(_ presenter: ImagesListPresenterProtocol)
    func updateTableViewAnimated(at indexPaths: [IndexPath])
    func setProgressHUDActive(_ isActive: Bool)
    func setLikeButton(at cell: ImagesListCell, active: Bool)
    func setCellLiked(cell: ImagesListCell, liked: Bool)
    func showLikeErrorAlert()
    func showSingleImageViewController(imageURL: URL?)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController, let imageURL = sender as? URL? else {
                assertionFailure("ImagesListViewController.prepare: Failed to create ViewController or extract url from sender")
                return
            }
            viewController.imageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
    
    func updateTableViewAnimated(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showSingleImageViewController(imageURL: URL?) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: imageURL)
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
        presenter?.cellTapped(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter else {
            assertionFailure("ImagesListViewController.tableView error: failed to get presenter")
            return tableView.rowHeight
        }
        let size = presenter.imageSize(at: indexPath.row)
        let tableWidth = tableView.contentSize.width
        let imageViewWidth = tableWidth - TableViewConstants.cellLateralHalfSpacing*2
        let imageViewHeight = imageViewWidth/(size.width)*(size.height)
        let rowHeight = imageViewHeight + TableViewConstants.cellVerticalHalfSpacing*2
        return rowHeight
    }
}


//MARK: - UIScrollViewDelegate
extension ImagesListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // there will be a lot of duplicated task requests for fetching photos
        // but now viewController is ignorant of number of photos
        // feels more separated
        let yOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        if yOffset > contentHeight - frameHeight * 2{
            presenter?.didScrollToBottom()
        }
    }
}


//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.feedLength ?? 0
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
        cell.configure(with: cellViewModel)
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
