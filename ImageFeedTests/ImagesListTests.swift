//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Vladimir on 16.04.2025.
//

@testable import ImageFeed
import XCTest


final class ImagesListTests: XCTestCase {
    
    final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
        
        var view: ImagesListViewControllerProtocol?
        var feedLength: Int {
            10
        }
        var viewDidLoadCalled = false
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func cellViewModel(for index: Int) -> CellViewModel {
            CellViewModel(imageURL: nil, dateString: "", isLiked: true)
        }
        
        func imageSize(at index: Int) -> CGSize {
            CGSize(width: 10, height: 10)
        }
        
        func likeButtonTapped(cell: ImageFeed.ImagesListCell, index: Int) { }
        
        func cellTapped(at index: Int) { }
        
        func didScrollToBottom() { }

    }
    
    final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
        
        var presenter: ImagesListPresenterProtocol?
        var didCallUpdateTable = false
        var didCallUpdateTableExpectation: XCTestExpectation?
        
        func updateTableViewAnimated(at indexPaths: [IndexPath]) {
            didCallUpdateTable = true
            didCallUpdateTableExpectation?.fulfill()
        }
        
        func setProgressHUDActive(_ isActive: Bool) {
                
        }
        
        func setLikeButton(at cell: ImageFeed.ImagesListCell, active: Bool) {
                
        }
        
        func setCellLiked(cell: ImageFeed.ImagesListCell, liked: Bool) {
                
        }
        
        func showLikeErrorAlert() {
                
        }
        
        func showSingleImageViewController(imageURL: URL?) {
                
        }
        
    }
    
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        imagesListVC.injectPresenter(presenterSpy)
        
        //when
        _ = imagesListVC.view
        
        //then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    
    func testDidScrollToBottomCallsDataUpdate() {
        // given
        let imagesListVCSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        imagesListVCSpy.injectPresenter(presenter)
        let expectation = XCTestExpectation(description: "didCallUpdateTable")
        imagesListVCSpy.didCallUpdateTableExpectation = expectation
        OAuth2TokenStorage.shared.token = "testToken"
        
        // when
        presenter.didScrollToBottom()
        
        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(imagesListVCSpy.didCallUpdateTable)
        
    }
    
}
