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
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: - Initializers
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        guard let request = authHelper.createAuthRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progressValue = Float(newValue)
        view?.setProgressValue(progressValue)
        
        let shouldHide = shouldHideProgress(for: progressValue)
        view?.setProgressHidden(shouldHide)
    }
    
    func code(from url: URL) -> String? {
        authHelper.getCode(from: url)
    }
    
    // MARK: - Private Methods
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1) < 0.0001
    }
    
}
