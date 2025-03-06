//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueID = "ShowWebView"
    weak var delegate: AuthViewContollerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueID {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to create WebViewContoller during authentication")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String) {
        //TODO: implement rendering result
        OAuth2Service.shared.fetchOAuthToken(from: code) { [weak self, weak vc] result in
            guard let self, let vc else { return }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                guard let delegate = self.delegate else {
                    assertionFailure("Failed to get AuthVC's delegate")
                    return
                }
                vc.dismiss(animated: true)
                delegate.didAuthenticate(self)
            case .failure(let error):
                break
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: UIViewController) {
        dismiss(animated: true)
    }
    
    
}
