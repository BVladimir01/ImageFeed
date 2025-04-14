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
        
        func didUpdateProgressValue(_ newValue: Double) {
            
        }
        
        func code(from url: URL) -> String? {
            nil
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

}
