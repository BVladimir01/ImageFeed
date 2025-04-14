//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Vladimir on 03.03.2025.
//

import UIKit
import WebKit


//MARK: - WebViewViewControllerDelegate
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: UIViewController, didAuthenticateWith code: String)
    func webViewViewControllerDidCancel(_ vc: UIViewController)
}


// MARK: - WebViewControllerProtocol
protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ value: Float)
    func setProgressHidden(_ isHidden: Bool)
}


//MARK: - WebViewViewController
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol{
    
    //MARK: - IBOutlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    //MARK: - Internal Properties
    
    weak var delegate: WebViewViewControllerDelegate? = nil
    var presenter: WebViewPresenterProtocol? = nil
    
    //MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewDidLoad()
        setActivityIndicator(active: false)
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change  in
            guard let newValue = change.newValue else {
                assertionFailure("WebViewViewController.viewWillAppear: failed to observe progress change -- no new value")
                return
            }
            self?.presenter?.didUpdateProgressValue(newValue)
        }
    }
    
    // MARK: - Internal Methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ value: Float) {
        progressView.progress = value
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    //MARK: - Private Methods
    
    private func setActivityIndicator(active: Bool) {
        if active {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
}


//MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            decisionHandler(.cancel)
            setActivityIndicator(active: true)
            self.delegate?.webViewViewController(self, didAuthenticateWith: code)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            presenter?.code(from: url)
        } else {
            nil
        }
    }
    
}
