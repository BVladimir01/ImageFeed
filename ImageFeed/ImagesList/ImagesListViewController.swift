//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 27.01.2025.
//


import Foundation
import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let imagesNames: [String] = Array(0..<20).map({"\($0)"})
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        guard let image = UIImage(named: imagesNames[indexPath.row]) else {
            fatalError("Could not create image for cell")
        }
        cell.cellImageView.image = image
        cell.cellImageView.layer.cornerRadius = 16
        cell.cellImageView.layer.masksToBounds = true
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.likeButton.imageView?.image = indexPath.row.isMultiple(of: 2) ? UIImage(named: "FavouritesActive") : UIImage(named: "FavouritesNonActive")
        
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: imagesNames[indexPath.row]) else {
            fatalError("could not extract image calculating cell's height")
        }
        let tableWidth = tableView.contentSize.width
//        subtract insets horizontal padding
        let imageViewWidth = tableWidth - 32
//        calculate with
        let imageViewHeight = imageViewWidth/(image.size.width)*(image.size.height)
//        add vertical padding
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
            fatalError("Could not type cast cell to ImagesListCell")
        }
        configCell(for: cell, at: indexPath)
        return cell
    }
    
    
}
