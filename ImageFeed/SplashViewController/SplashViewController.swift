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
    private let authNavigationControllerID = "AuthRootViewController"
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkToken()
    }
    
    //MARK: - Private Methods
    
    private func setupImageView() {
        let imageView = UIImageView(image: UIImage(resource: .splashScreenLogo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75)
        ])
        view.backgroundColor = .ypBlack
    }
    
    private func switchToTabBarViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("SplashViewController.switchToTabBarViewController: Failed to get windowScene or its window when switching to TabBarVC from splashscreen")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: tabBarStoryboardID)
        window.rootViewController = tabBarVC
    }
    
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authNavigationController = (storyboard.instantiateViewController(withIdentifier: authNavigationControllerID) as? UINavigationController) else {
            assertionFailure("SplashViewController.switchToAuthViewController: Failed to instantiate \(authNavigationControllerID) from storyboard when switching to AuthVC from splashscreen")
            return
        }
        guard let authVC = authNavigationController.topViewController as? AuthViewController else {
            assertionFailure("SplashViewController.switchToAuthViewController: failed to get AuthViewController as top view controller of \(authNavigationControllerID)")
            return
        }
        authVC.delegate = self
        authNavigationController.modalPresentationStyle = .fullScreen
        present(authNavigationController, animated: true)
    }
    
    private func checkToken() {
        if let token = tokenStorage.token {
            fetchProfile(for: token)
        } else {
            switchToAuthViewController()
        }
    }
    
}


//MARK: - AuthViewContollerDelegate
extension SplashViewController: AuthViewContollerDelegate {
    
    func didAuthenticate(_ vc: UIViewController) {
        vc.dismiss(animated: true)
        guard let token = tokenStorage.token else {
            assertionFailure("SplashViewController.didAuthenticate: Failed to load token after authentication")
            return
        }
        // profile is being fetched here and
        // when top view is dismissed, since
        // viewDidLoad and checkToken will be executed
        // does not seem to be a bug, more like
        // intentional behaviour
        fetchProfile(for: token)
    }
    
    private func fetchProfile(for token: String) {
        UIBlockingHUD.show()
        profileService.fetchProfile(for: token) { [weak self] result in
            switch result {
            case .success(let profile):
                UIBlockingHUD.dismiss()
                self?.profileImageService.fetchProfileImageURL(username: profile.username, completion: { _ in })
                self?.switchToTabBarViewController()
            case .failure(let error):
                UIBlockingHUD.dismiss()
                //TODO: implement failure
                break
            }
        }
    }
    
}
