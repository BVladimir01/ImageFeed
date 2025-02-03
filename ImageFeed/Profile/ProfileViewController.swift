//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit

class ProfileViewController: UIViewController {

    //MARK: - @IBOutlet vars
    
    @IBOutlet private var profileDescriptionLabel: UILabel!
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var tagLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var logOutButton: UIButton!
    
    @IBAction func logOutButtonTapped() {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
