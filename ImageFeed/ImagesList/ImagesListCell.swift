//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Vladimir on 28.01.2025.
//

import UIKit


final class ImagesListCell: UITableViewCell {
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
}
