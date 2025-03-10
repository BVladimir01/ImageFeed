//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit

protocol AuthViewContollerDelegate: AnyObject {
    func didAuthenticate(_ vc: UIViewController)
}

final class AuthViewController: UIViewController {
    
    //MARK: - vars
    
    private let showWebViewVCSegueID = "ShowWebView"
    weak var delegate: AuthViewContollerDelegate?
    
    //MARK: - overriden methond

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }
        if segue.identifier == showWebViewVCSegueID {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to create WebViewVC as a segue destination from AuthViewVC")
                return
            }
            webViewVC.delegate = self
        }
    }
}

//MARK: - WebViewVCDelegate conformance

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String) {
        //TODO: implement result processing
        OAuth2Service.shared.fetchOAuthToken(from: code) { [weak self] result in
            guard let self else { return }
            guard let delegate = self.delegate else {
                assertionFailure("Failed to get AuthVC's delegate")
                return
            }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                vc.dismiss(animated: true)
                delegate.didAuthenticate(self)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
}
