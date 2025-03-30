//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Vladimir on 28.01.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    // MARK: - Internal Properties
    
    static let reuseIdentifier = "ImagesListCell"
    var imageIsLoaded = false
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        imageIsLoaded = false
    }
}
