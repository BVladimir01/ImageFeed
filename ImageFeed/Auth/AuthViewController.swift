//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit


//MARK: - AuthViewControllerDelegate
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: UIViewController)
}


//MARK: - AuthViewController
final class AuthViewController: UIViewController {
    
    //MARK: - Internal Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    //MARK: - Private Properties
    
    private let showWebViewVCSegueID = "ShowWebView"
    private let alertPresenter = SimpleAlertPresenter()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        print("AuthViewController.viewDidLoad")
        super.viewDidLoad()
        setupNavigationBar()
        setupAlertPresenter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        if segue.identifier == showWebViewVCSegueID {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("AuthViewController.prepare: Failed to create WebViewVC as a segue destination from AuthViewVC")
                return
            }
            let authHelper = AuthHelper(configuration: .standard)
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewVC.delegate = self
            webViewVC.presenter = webViewPresenter
            webViewPresenter.view = webViewVC
        }
    }
    
    //MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    private func setupAlertPresenter() {
        alertPresenter.delegate = self
    }
    
}


//MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String) {
        //use pop since whole stack is presented modally
        navigationController?.popViewController(animated: true)
        UIBlockingHUD.show()
        OAuth2Service.shared.fetchOAuthToken(from: code) { [weak self] result in
            guard let self else { return }
            guard let delegate = self.delegate else {
                assertionFailure("AuthViewController.webViewViewController: Failed to get AuthVC's delegate")
                return
            }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                UIBlockingHUD.dismiss()
                delegate.didAuthenticate(self)
            case .failure:
                UIBlockingHUD.dismiss()
                alertPresenter.presentAlert(SimpleAlertModel(title: "Что-то пошло не так", message: "Не удалось войти в систему", buttonText: "Ок"))
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
}
