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
    
    // MARK: - Private Methods
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientStart = NSNumber(value: 1 - 30/Float(cellImageView.bounds.height))
        gradientLayer?.locations = [gradientStart, 1]
        gradientLayer?.frame = cellImageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        imageIsLoaded = false
    }
    
    // MARK: - Private Methods
    
    private func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
//        let gradientStart = NSNumber(value: 1 - 30/Float(cell.cellImageView.bounds.height))
        gradient.locations = [1, 1]
        cellImageView.layer.addSublayer(gradient)
        gradientLayer = gradient
    }
}
