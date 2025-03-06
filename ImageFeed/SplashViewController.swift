//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import UIKit

class SplashViewController: UIViewController {
    
    private let tabBarStoryboardID = "TabBarVC"
    private let showAuthSegueID = "ShowAuthVC"
    
    override func viewDidAppear(_ animated: Bool) {
        let storage = OAuth2TokenStorage.shared
//        storage.token = nil
        if let _ = storage.token {
            switchToFeedViewController()
        } else {
            performSegue(withIdentifier: showAuthSegueID, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        guard segue.identifier == showAuthSegueID else { return }
        guard let navigationVC = segue.destination as? UINavigationController else {
            assertionFailure("Failed to typecast navigationController during authentication")
            return
        }
        guard let authVC = navigationVC.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to get or typecast AuthViewController")
            return
        }
        authVC.delegate = self
    }
    
    private func switchToFeedViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("Failed to get windowScene or window")
            return
        }
        guard let feedVC = storyboard?.instantiateViewController(withIdentifier: tabBarStoryboardID) else {
            assertionFailure("Failed to instantiate \(tabBarStoryboardID) from storyboard")
            return
        }
        window.rootViewController = feedVC
    }
}

extension SplashViewController: AuthViewContollerDelegate {
    func didAuthenticate(_ vc: UIViewController) {
        vc.dismiss(animated: true)
        switchToFeedViewController()
    }
}
