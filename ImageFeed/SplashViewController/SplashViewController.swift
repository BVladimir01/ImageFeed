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
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75)
        ])
        view.backgroundColor = .ypBlack
    }
    
    private func switchToTabBarViewController(profileService: ProfileServiceProtocol,
                                              profileImageService: ProfileImageServiceProtocol) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("SplashViewController.switchToTabBarViewController: Failed to get windowScene or its window when switching to TabBarVC from splashscreen")
            return
        }
        guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: tabBarStoryboardID) as? TabBarViewController else {
            assertionFailure("SplashViewController.switchToTabBarViewController error: Failed to typecast TabBarViewController")
            return
        }
        tabBarVC.profileService = profileService
        tabBarVC.profileImageService = profileImageService
        tabBarVC.attachViewControllers()
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


//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
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
        // intentional behavior
        fetchProfile(for: token)
    }
    
    private func fetchProfile(for token: String) {
        UIBlockingHUD.show()
        let profileService = ProfileService()
        let profileImageService = ProfileImageService()
        profileService.fetchProfile(for: token) { [weak self] result in
            switch result {
            case .success(let profile):
                UIBlockingHUD.dismiss()
                profileImageService.fetchProfileImageURL(username: profile.username, completion: { _ in })
                self?.switchToTabBarViewController(profileService: profileService, profileImageService: profileImageService)
            case .failure(let error):
                UIBlockingHUD.dismiss()
                // wonder if this recurrent call is ok here
                // much better to show alert here
                // may be later not for praktikum
                self?.fetchProfile(for: token)
                break
            }
        }
    }
    
}
