//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebViewVCSegueID = "ShowWebView"
    weak var delegate: AuthViewContollerDelegate?

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

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String) {
        //TODO: implement result processing
        OAuth2Service.shared.fetchOAuthToken(from: code) { [weak self, weak vc] result in
            guard let self, let vc else { return }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                vc.dismiss(animated: true)
                guard let delegate = self.delegate else {
                    assertionFailure("Failed to get AuthVC's delegate")
                    return
                }
                delegate.didAuthenticate(self)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: UIViewController) {
        dismiss(animated: true)
    }
    
    
}
