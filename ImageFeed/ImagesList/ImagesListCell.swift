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
    weak var delegate: ImagesListCellDelegate?
    private(set) var imageIsLoaded = false
    
    // MARK: - Private Methods
    
    private var gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientStart = NSNumber(value: 1 - 30/Float(cellImageView.bounds.height))
        gradientLayer.locations = [gradientStart, 1]
        gradientLayer.frame = cellImageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        imageIsLoaded = false
    }
    
    // MARK: - Internal Methods
    
    func imageLoaded() {
        imageIsLoaded = true
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .favouritesActive) : UIImage(resource: .favouritesNonActive)
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setupGradient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradientLayer.locations = [1, 1]
        cellImageView.layer.addSublayer(gradientLayer)
        //remove animations on cell update
        gradientLayer.actions = [
            "position": NSNull(),
            "bounds": NSNull(),
            "opacity": NSNull(),
            "contents": NSNull()
        ]
    }
    
    // MARK: - IBActions
    
    @IBAction private func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(cell: self)
    }
}
