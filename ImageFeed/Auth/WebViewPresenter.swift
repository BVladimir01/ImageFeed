//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Vladimir on 14.04.2025.
//

import UIKit


// MARK: - WebViewPresenterProtocol
protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}


// MARK: - WebViewPresenterProtocol
final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Internal Properties
    
    weak var view: WebViewViewControllerProtocol? = nil
    
    // MARK: - Private Properties
    
    private let unsplashAuthorizeUrlString = "https://unsplash.com/oauth/authorize"
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        loadRequest()
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progressValue = Float(newValue)
        view?.setProgressValue(progressValue)
        
        let shouldHide = shouldHideProgress(for: progressValue)
        view?.setProgressHidden(shouldHide)
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code"} )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldHideProgress(for value: Float) -> Bool {
        return abs(value - 1) < 0.0001
    }
    
    private func loadRequest() {
        guard var urlComponents = URLComponents(string: unsplashAuthorizeUrlString) else {
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
        view?.load(request: request)
    }
}
