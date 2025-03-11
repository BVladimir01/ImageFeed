//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import UIKit


final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    
    private let tabBarStoryboardID = "TabBarVC"
    private let showAuthSegueID = "ShowAuthVC"
    
    //MARK: - Lifycycle
    
    override func viewDidAppear(_ animated: Bool) {
        checkToken()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        guard segue.identifier == showAuthSegueID else { return }
        guard let navigationVC = segue.destination as? UINavigationController else {
            assertionFailure("Failed to typecast NavigationController of authenctication flow from SplashVC")
            return
        }
        guard let authVC = navigationVC.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to get or typecast AuthVC from NavigationController of authentication flow")
            return
        }
        authVC.delegate = self
    }
    
    //MARK: - Private Methods
    
    private func switchToTabBarViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("Failed to get windowScene or its window when switching to TabBarVC from splashscreen")
            return
        }
        guard let tabBarVC = storyboard?.instantiateViewController(withIdentifier: tabBarStoryboardID) else {
            assertionFailure("Failed to instantiate \(tabBarStoryboardID) from storyboard when switching to TabBarVC from splashscreen")
            return
        }
        window.rootViewController = tabBarVC
    }
    
    private func checkToken() {
        let storage = OAuth2TokenStorage.shared
        if storage.token != nil {
            switchToTabBarViewController()
        } else {
            performSegue(withIdentifier: showAuthSegueID, sender: nil)
        }
    }
    
}


//MARK: - AuthViewContollerDelegate
extension SplashViewController: AuthViewContollerDelegate {
    
    func didAuthenticate(_ vc: UIViewController) {
        vc.dismiss(animated: true)
        switchToTabBarViewController()
    }
    
}
