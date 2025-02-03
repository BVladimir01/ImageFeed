//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    //MARK: - vars
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    //MARK: - @IBOutlet vars
    
    @IBOutlet private var imageView: UIImageView!
    
    
    //MARK: - @IBOutlet actions
    
    @IBAction func backwardButtonTapped() {
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Do any additional setup after loading the view.
    }
    

}
