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
        guard let imagesListNavigation = setUpImagesListAndReturnVC() else { return }
        let profileVC = setUpProfileAndReturnVC()
        viewControllers = [imagesListNavigation, profileVC]
    }
    
    // MARK: - Private Methods
    
    private func setUpProfileAndReturnVC() -> UIViewController {
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenter(profileService: ProfileService.shared,
                                         profileImageService: ProfileImageService.shared,
                                         profileLogoutService: ProfileLogoutService.shared)
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
        let presenter = ImagesListPresenter(imagesListService: ImagesListService.shared)
        imagesListVC.injectPresenter(presenter)
        return imagesListNavigation
    }
    
}
