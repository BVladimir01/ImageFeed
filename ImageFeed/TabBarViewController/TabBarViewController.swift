//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 28.03.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Private Properties

    let imagesListNavigationControllerID = "ImagesListNavigationViewController"

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(resource: .tabProfileNonActive), selectedImage: UIImage(resource: .tabProfileActive))
        let imagesListNavigation = storyboard.instantiateViewController(withIdentifier: imagesListNavigationControllerID)
        
        viewControllers = [imagesListNavigation, profileVC]
    }
    
}
