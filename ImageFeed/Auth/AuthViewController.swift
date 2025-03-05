//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueID = "ShowWebView"

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
        //TODO: implement authentication
    }
    
    func webViewViewControllerDidCancel(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
