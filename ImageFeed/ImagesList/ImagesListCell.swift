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
    
    // MARK: - Private Methods
    
    private var gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        layer.cornerRadius = 16
        layer.masksToBounds = true
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1 - 30/cellImageView.bounds.height)
        gradientLayer.frame = cellImageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    // MARK: - Internal Methods
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .favouritesActive) : UIImage(resource: .favouritesNonActive)
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setupGradient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        cellImageView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - IBActions
    
    @IBAction private func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(cell: self)
    }
}
