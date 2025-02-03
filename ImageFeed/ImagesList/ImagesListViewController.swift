//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//


import Foundation
import UIKit

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let imagesNames: [String] = Array(0..<20).map({"\($0)"})
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.rowHeight = 200
    }
    
    private func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        guard let image = UIImage(named: imagesNames[indexPath.row]) else {
            assertionFailure("Failed to create image for cell")
            return
        }
        cell.cellImageView.image = image
        cell.cellImageView.layer.cornerRadius = 16
        cell.cellImageView.layer.masksToBounds = true
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        cell.likeButton.imageView?.image = indexPath.row.isMultiple(of: 2) ? UIImage(named: "FavouritesActive") : UIImage(named: "FavouritesNonActive")
    }
}


extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController, let indexPath = sender as? IndexPath else {
                assertionFailure("Failed to create ViewController or extract indexPath")
                return
            }
            let image = UIImage(named: "\(imagesNames[indexPath.row])")
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: imagesNames[indexPath.row]) else {
            assertionFailure("Failed to extract image for calculating cell's height")
            return tableView.rowHeight
        }
        let tableWidth = tableView.contentSize.width
        let imageViewWidth = tableWidth - 32
        let imageViewHeight = imageViewWidth/(image.size.width)*(image.size.height)
        let rowHeight = imageViewHeight + 8
        return rowHeight
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            assertionFailure("Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }
        configCell(for: cell, at: indexPath)
        return cell
    }
}
