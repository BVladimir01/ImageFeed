//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 14.04.2025.
//

import UIKit


// MARK: - ProfilePresenterProtocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func logoutTapped()
    func confirmLogout()
    func viewDidLoad()
}


// MARK: - ProfielPresenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Internal Properties
    
    weak var view: ProfileViewControllerProtocol? = nil
    
    // MARK: - Private Properties
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    // MARK: - Initializers
    
    init(profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    // MARK: - Internal Methods
    
    func logoutTapped() {
        view?.showLogoutAlert()
    }
    
    func confirmLogout() {
        profileLogoutService.logout()
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else {
            assertionFailure("ProfilePresenter.viewDidLoad: Failed to get profile from service when setting up users profile")
            return
        }
        setUpLogoutService()
        view?.setProfileDetails(profile: profile)
        addProfileImageServiceObserver()
        updateProfileImage()
    }
    
    // MARK: - Private Methods
    
    private func addProfileImageServiceObserver() {
        let profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: profileImageService, queue: .main) { [weak self] _ in
            self?.updateProfileImage()
        }
        self.profileImageServiceObserver = profileImageServiceObserver
    }
    
    private func updateProfileImage() {
        guard let avatarURL = profileImageService.avatarURL, let url = URL(string: avatarURL) else {
            print("ProfileViewController.updateProfileImage: Failed to get url for fetching avatar image")
            return
        }
        view?.setProfileImage(url: url)
    }
    
    private func setUpLogoutService() {
        profileLogoutService.delegate = self
    }
    
}


// MARK: - ProfileLogoutServiceDelegate
extension ProfilePresenter: ProfileLogoutServiceDelegate {
    func logoutServiceDidFinishCleanUp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            assertionFailure("ProfileLogoutService.switchToSplashScreen: Failed to get windowScene or its window when switching to splashscreen on logout")
            return
        }
        let splashScreen = SplashViewController()
        window.rootViewController = splashScreen
    }
}
