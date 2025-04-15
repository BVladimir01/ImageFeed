//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import Kingfisher
import UIKit



protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func initiatedLogout()
    func setProfileDetails(profile: Profile)
    func setProfileImage(url: URL)
    func cleanUpProfile()
    func injectPresenter(_ presenter: ProfilePresenterProtocol)
}

extension ProfileViewControllerProtocol {
    func injectPresenter(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}


final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Internal Properties
    
    var presenter: ProfilePresenterProtocol?

    //MARK: - Private Properties
    
    private var profileImageView: UIImageView!
    private var tagLabel: UILabel!
    private var nameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    private var logOutButton: UIButton!
    
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
        presenter?.viewDidLoad()
    }
    
    // MARK: - Internal Methods()
    
    func cleanUpProfile() {
        guard isViewLoaded else {
            assertionFailure("ProfileViewController.clearProfile: Failed to clean profile: profile is not loaded yet")
            return
        }
        profileImageView.image = nil
        tagLabel.text = nil
        nameLabel.text = nil
        profileDescriptionLabel.text = nil
    }
    
    func setProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        tagLabel.text = profile.loginName
        profileDescriptionLabel.text = profile.bio
    }
    
    func setProfileImage(url: URL) {
        profileImageView.kf.setImage(with: url) { [weak self] _ in
            guard let self else { return }
            self.adjustProfileImageSize()
        }
    }
    
    @objc
    func initiatedLogout() {
        let ac = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] action in
            //seems like it should be performed on main
            DispatchQueue.main.async {
                self?.presenter?.logOut()
            }
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
        ac.preferredAction = cancelAction
        present(ac, animated: true)
    }
    
    // MARK: - Private Methods

    private func adjustProfileImageSize() {
        guard let image = profileImageView.image, let cgImage = image.cgImage else { return }
        let width = image.size.width
        let height = image.size.height
        let vScale = 70/height
        let hScale = 70/width
        let trueScale = max(vScale, hScale)
        let newImage = UIImage(cgImage: cgImage, scale: 1/trueScale, orientation: .up)
        profileImageView.image = newImage
    }
    
    //MARK: - Private Methods - Configuration / SubViews Layout
    
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.masksToBounds = true
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
        button.addTarget(self, action: #selector(initiatedLogout), for: .touchUpInside)
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

}
