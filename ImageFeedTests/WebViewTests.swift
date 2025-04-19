//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Vladimir on 14.04.2025.
//

@testable import ImageFeed
import XCTest


final class WebViewTests: XCTestCase {
    
    final class WebViewPresenterSpy: WebViewPresenterProtocol {
        
        var viewDidLoadCalled = false
        var view: WebViewViewControllerProtocol?
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func didUpdateProgressValue(_ newValue: Double) { }
        
        func code(from url: URL) -> String? { nil }
        
    }
    
    final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
        
        var loadRequestCalled = false
        var progressIsHidden: Bool?
        var presenter: (any ImageFeed.WebViewPresenterProtocol)?
        
        func load(request: URLRequest) {
            loadRequestCalled = true
        }
        
        func setProgressValue(_ value: Float) { }
        
        func setProgressHidden(_ isHidden: Bool) { 
            progressIsHidden = isHidden
        }
    
    }

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        webViewViewController.presenter = presenter
        presenter.view = webViewViewController
        
        // when
        _ = webViewViewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        let webViewViewControllerSpy = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        webViewViewControllerSpy.presenter = presenter
        presenter.view = webViewViewControllerSpy
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(webViewViewControllerSpy.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let webViewViewControllerSpy = WebViewViewControllerSpy()
        webViewViewControllerSpy.presenter = presenter
        presenter.view = webViewViewControllerSpy
        let progress = 0.6
        
        // when
        presenter.didUpdateProgressValue(progress)
        
        // then
        if let isHidden = webViewViewControllerSpy.progressIsHidden {
            XCTAssertFalse(isHidden)
        } else {
            XCTFail("Did not update progress bar")
        }
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let webViewViewControllerSpy = WebViewViewControllerSpy()
        webViewViewControllerSpy.presenter = presenter
        presenter.view = webViewViewControllerSpy
        let progress = 1.0
        
        // when
        presenter.didUpdateProgressValue(progress)
        
        // then
        if let isHidden = webViewViewControllerSpy.progressIsHidden {
            XCTAssertTrue(isHidden)
        } else {
            XCTFail("Did not update progress bar")
        }
    }
    
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let helper = AuthHelper(configuration: configuration)
        
        // when
        guard let urlString = helper.authURL()?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        // then
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains(configuration.unsplashAuthURLString))
    }

    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents!.url!
        let helper = AuthHelper(configuration: .standard)
        
        print(url)
        // when
        let resultCode = helper.getCode(from: url)
        
        //then
        XCTAssertEqual(resultCode, "test code")
    }
}
