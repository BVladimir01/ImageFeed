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
        let presenter = ProfilePresenter(profileService: ProfileService.shared,
                                         profileImageService: ProfileImageService.shared,
                                         profileLogoutService: ProfileLogoutService.shared)
        profileVC.injectPresenter(presenter)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(resource: .tabProfileNonActive), selectedImage: UIImage(resource: .tabProfileActive))
        
        guard let imagesListNavigation = storyboard.instantiateViewController(withIdentifier: imagesListNavigationControllerID) as? UINavigationController else {
            assertionFailure("TabBarViewController.awakeFromNib failed to typecast navigation controller of image feed")
            return
        }
        guard let imagesListVC = imagesListNavigation.viewControllers.first(where: { $0 is ImagesListViewControllerProtocol }) as? ImagesListViewControllerProtocol else {
            assertionFailure("TabBarViewController.awakeFromNib failed to typecast ImagesListViewController as ImagesListViewControllerProtocol")
            return
        }
        imagesListVC.injectPresenter(ImagesListPresenter())
        viewControllers = [imagesListNavigation, profileVC]
    }
    
}
