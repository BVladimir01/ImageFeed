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


//MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    //MARK: - Internal Properties
    
    weak var delegate: WebViewViewControllerDelegate? = nil
    
    //MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private enum WebViewConstants {
        static let unsplashAuthorizeUrlString = "https://unsplash.com/oauth/authorize"
    }
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAuthView()
        setActivityIndicator(active: false)
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, _ in
            self?.updateProgressView()
        }
    }
    
    //MARK: - Private Methods
    
    private func updateProgressView() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = abs(progressView.progress - 1) < 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeUrlString) else {
            assertionFailure("WebViewViewController.loadAuthView: Failed to create URLComponents for authorization")
            return
        }
        urlComponents.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            assertionFailure("WebViewViewController.loadAuthView: Faield to create URL from URLComponents for authorization")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
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
        if let url = navigationAction.request.url,
              let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code"} )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}
