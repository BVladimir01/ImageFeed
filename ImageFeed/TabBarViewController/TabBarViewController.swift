//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 28.03.2025.
//

import UIKit


final class TabBarViewController: UITabBarController {
    
    // MARK: - Internal Properties
    
    var profileService: ProfileServiceProtocol?
    var profileImageService: ProfileImageServiceProtocol?
    
    // MARK: - Private Properties

    let imagesListNavigationControllerID = "ImagesListNavigationViewController"

    // MARK: - Internal Methods
    
    func attachViewControllers() {
        guard let imagesListNavigation = setUpImagesListAndReturnVC(), let profileVC = setUpProfileAndReturnVC() else { return }
        viewControllers = [imagesListNavigation, profileVC]
    }
    
    // MARK: - Private Methods
    
    private func setUpProfileAndReturnVC() -> UIViewController? {
        guard let profileService, let profileImageService else {
            assertionFailure("TabBarViewController.setUpProfileAndReturnVC error: profileService or profileImageService are nil")
            return nil
        }
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: ProfileLogoutService())
        profileVC.injectPresenter(presenter)
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(resource: .tabProfileNonActive), selectedImage: UIImage(resource: .tabProfileActive))
        return profileVC
    }
    
    private func setUpImagesListAndReturnVC() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListNavigation = storyboard.instantiateViewController(withIdentifier: imagesListNavigationControllerID) as? UINavigationController else {
            assertionFailure("TabBarViewController.awakeFromNib failed to typecast navigation controller of image feed")
            return nil
        }
        guard let imagesListVC = imagesListNavigation.viewControllers.first(where: { $0 is ImagesListViewControllerProtocol }) as? ImagesListViewControllerProtocol else {
            assertionFailure("TabBarViewController.awakeFromNib failed to typecast ImagesListViewController as ImagesListViewControllerProtocol")
            return nil
        }
        let presenter = ImagesListPresenter(imagesListService: ImagesListService())
        imagesListVC.injectPresenter(presenter)
        return imagesListNavigation
    }
    
}
