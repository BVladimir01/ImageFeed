//
//  ViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.02.2025.
//

import Kingfisher
import UIKit


// MARK: - ProfileViewControllerProtocol
protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func showLogoutAlert()
    func setProfileDetails(profile: Profile)
    func setProfileImage(url: URL)
    func injectPresenter(_ presenter: ProfilePresenterProtocol)
}

extension ProfileViewControllerProtocol {
    func injectPresenter(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}


// MARK: - ProfileViewController
final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Internal Properties
    
    var presenter: ProfilePresenterProtocol?

    //MARK: - Private Properties
    
    private var profileImageView: UIImageView!
    private var tagLabel: UILabel!
    private var nameLabel: UILabel!
    private var profileDescriptionLabel: UILabel!
    private var logOutButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ViewConstants.backgroundColor
        configureSubViews()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Internal Methods()
    
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
    
    func showLogoutAlert() {
        let ac = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] action in
            //seems like it should be performed on main
            DispatchQueue.main.async {
                self?.presenter?.confirmLogout()
            }
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default)
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
        ac.preferredAction = cancelAction
        present(ac, animated: true)
    }
    
    @objc
    private func initiateLogout() {
        presenter?.logoutTapped()
    }
    
    // MARK: - Private Methods

    private func adjustProfileImageSize() {
        guard let image = profileImageView.image, let cgImage = image.cgImage else { return }
        let width = image.size.width
        let height = image.size.height
        let vScale = ViewConstants.profileImageViewHeight/height
        let hScale = ViewConstants.profileImageViewWidth/width
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
        let imageView = UIImageView(image: UIImage(resource: .profilePicStubLarge))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, 
                                           constant: ViewConstants.profileImageViewTopToViewTop),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: ViewConstants.profileImageViewLeadingToViewLeading),
            imageView.heightAnchor.constraint(equalToConstant: ViewConstants.profileImageViewHeight),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor,
                                             multiplier: ViewConstants.profileImageViewWidthToHeight)
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
        label.numberOfLines = ViewConstants.nameLabelNumberOfLines
        label.font = .systemFont(ofSize: ViewConstants.nameLabelFontSize, weight: .semibold)
        label.textColor = ViewConstants.nameLabelFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: ViewConstants.nameLabelLeadingToViewLeading),
            label.topAnchor.constraint(equalTo: profileImageView.bottomAnchor,
                                       constant: ViewConstants.nameLabelTopToProfileImageViewBottom),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        nameLabel = label
    }
    
    private func configureTagLabel() {
        let label = UILabel()
        label.text = "@Tag label"
        label.numberOfLines = ViewConstants.tagLabelNumberOfLines
        label.font = .systemFont(ofSize: ViewConstants.tagLabelFontSize, weight: .regular)
        label.textColor = ViewConstants.tagLabelFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: ViewConstants.tagLabelLeadingToViewLeading),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                       constant: ViewConstants.tagLabelTopToNameLabelBottom),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        tagLabel = label
    }
    
    private func configureProfileDescriptionLabel() {
        let label = UILabel()
        label.text = "Profile description label"
        label.numberOfLines = ViewConstants.profileDescriptionLabelNumberOfLines
        label.font = .systemFont(ofSize: ViewConstants.profileDescriptionLabelFontSize, weight: .regular)
        label.textColor = ViewConstants.profileDescriptionLabelFontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                           constant: ViewConstants.profileDescriptionLabelLeadingToViewLeading),
            label.topAnchor.constraint(equalTo: tagLabel.bottomAnchor,
                                       constant: ViewConstants.profileDescriptionLabelTopToTagLabelBottom),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
        profileDescriptionLabel = label
    }
    
    private func configureLogOutButton() {
        let button = UIButton()
        button.setImage(UIImage(resource: .logOut), for: .normal)
        button.addTarget(self, action: #selector(initiateLogout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                             constant: ViewConstants.logoutTrailingToViewTrailing),
            button.heightAnchor.constraint(equalToConstant: ViewConstants.logoutButtonHeight),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: ViewConstants.logoutButtonWidthToHeight)
        ])
        logOutButton = button
    }

}


// MARK: - ViewConstants
extension ProfileViewController {
    private struct ViewConstants {
        
        private init() { }
        
        static let backgroundColor: UIColor = .ypBlack
        
        static let profileImageViewTopToViewTop: CGFloat = 76
        static let profileImageViewLeadingToViewLeading: CGFloat = 16
        static let profileImageViewHeight: CGFloat = 70
        static let profileImageViewWidthToHeight: CGFloat = 1
        static var profileImageViewWidth: CGFloat {
            profileImageViewHeight * profileImageViewWidthToHeight
        }
        
        static let nameLabelNumberOfLines: Int = 1
        static let nameLabelFontSize: CGFloat = 23
        static let nameLabelFontColor: UIColor = .ypWhite
        static let nameLabelLeadingToViewLeading: CGFloat = 16
        static let nameLabelTopToProfileImageViewBottom: CGFloat = 8
        
        static let tagLabelNumberOfLines: Int = 1
        static let tagLabelFontSize: CGFloat = 13
        static let tagLabelFontColor: UIColor = .ypGray
        static let tagLabelLeadingToViewLeading: CGFloat = 16
        static let tagLabelTopToNameLabelBottom: CGFloat = 8
        
        static let profileDescriptionLabelNumberOfLines: Int = 1
        static let profileDescriptionLabelFontSize: CGFloat = 13
        static let profileDescriptionLabelFontColor: UIColor = .ypWhite
        static let profileDescriptionLabelLeadingToViewLeading: CGFloat = 16
        static let profileDescriptionLabelTopToTagLabelBottom: CGFloat = 8
        
        static let logoutTrailingToViewTrailing: CGFloat = -14
        static let logoutButtonHeight: CGFloat = 44
        static let logoutButtonWidthToHeight: CGFloat = 1
        
    }
}
