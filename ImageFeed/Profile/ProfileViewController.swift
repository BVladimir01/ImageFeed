//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import UIKit

class ProfileViewController: UIViewController {

    //MARK: - Private label vars
    
    private var profileImageView: UIImageView!
    private var tagLabel: UILabel!
    private var nameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    private var logOutButton: UIButton!
    
    private struct SymbolNames {
        private init() {}
        static let profileImage = "ProfilePicStubLarge"
        static let logoutButton = "LogOut"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configureSubViews()
    }
    
    //MARK: - Configuration
    
    private func configureSubViews() {
        configureProfileImageView()
        configureNameLabel()
        configureTagLabel()
        configureProfileDescriptionLabel()
        configureLogOutButton()
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
    
    //MARK: - Intentions
    @objc
    private func logOut() {
        //TODO: log out logic
    }

}
