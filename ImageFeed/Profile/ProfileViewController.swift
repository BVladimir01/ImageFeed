//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit


final class ProfileViewController: UIViewController {

    //MARK: - Private Properties
    
    private var profileImageView: UIImageView!
    private var tagLabel: UILabel!
    private var nameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    private var logOutButton: UIButton!
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private struct SymbolNames {
        static let profileImage = "ProfilePicStubLarge"
        static let logoutButton = "LogOut"
        private init() {}
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configureSubViews()
        setUpProfile()
    }
    
    //MARK: - Private Methods - Configuration
    
    private func configureSubViews() {
        configureProfileImageView()
        configureNameLabel()
        configureTagLabel()
        configureProfileDescriptionLabel()
        configureLogOutButton()
        addProfileImageServiceObserver()
        updateAvatar()
    }
    
    private func configureProfileImageView() {
        let imageView = UIImageView(image: UIImage(named: SymbolNames.profileImage))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
        ])
        profileImageView = imageView
    }
    
    private func configureNameLabel() {
        let label = UILabel()
        label.text = "Name label"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        nameLabel = label
    }
    
    private func configureTagLabel() {
        let label = UILabel()
        label.text = "@Tag label"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        tagLabel = label
    }
    
    private func configureProfileDescriptionLabel() {
        let label = UILabel()
        label.text = "Profile description label"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        profileDescriptionLabel = label
    }
    
    private func configureLogOutButton() {
        let button = UIButton()
        button.setImage(UIImage(named: SymbolNames.logoutButton), for: .normal)
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1)
        ])
        logOutButton = button
    }
    
    private func setUpProfile() {
        guard let profile = profileService.profile else {
            assertionFailure("Failed to get profile from service when setting up users profile")
            return
        }
        updateProfileDetails(profile: profile)
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        tagLabel.text = profile.loginName
        profileDescriptionLabel.text = profile.bio
    }
    
    private func addProfileImageServiceObserver() {
        let profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateAvatar()
        }
        self.profileImageServiceObserver = profileImageServiceObserver
    }
    
    private func updateAvatar() {
        guard let avatarURL = profileImageService.avatarURL, let url = URL(string: avatarURL) else {
            assertionFailure("Failed to create url for fetching avatar image")
            return
        }
        // TODO: change avatar
        print("avatar changed with \(url)")
    }
    
    //MARK: - Private Methods - UIActions
    
    @objc
    private func logOut() {
        //TODO: log out implementation
        OAuth2TokenStorage.shared.token = nil
    }

}
