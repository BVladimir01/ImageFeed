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
        var didCallSetCellLiked = false
        var didSetCellToLike = false
        var didCallShowLikeErrorAlert = false
        var didCallShowSingleImageViewController = false
        var urlOfSingleImageViewController: URL?
        
        func updateTableViewAnimated(at indexPaths: [IndexPath]) {
            didCallUpdateTable = true
            didCallUpdateTableExpectation?.fulfill()
        }
        
        func setProgressHUDActive(_ isActive: Bool) { }
        
        func setLikeButton(at cell: ImageFeed.ImagesListCell, active: Bool) { }
        
        func setCellLiked(cell: ImageFeed.ImagesListCell, liked: Bool) {
            didCallSetCellLiked = true
            didSetCellToLike = liked
        }
        
        func showLikeErrorAlert() {
            didCallShowLikeErrorAlert = true
        }
        
        func showSingleImageViewController(imageURL: URL?) {
            didCallShowSingleImageViewController = true
            urlOfSingleImageViewController = imageURL
        }
        
    }
    
    final class ImagesListServiceMock: ImagesListServiceProtocol {
        
        var changeLikeSuccessful = false
        var didCallFetchPhotos = false
        
        var photos: [Photo] = [
            Photo(id: "testID",
                  size: CGSize(width: 10, height: 10),
                  createdAt: ISO8601DateFormatter().date(from: "2025-04-17T00:00:00Z"),
                  welcomeDescription: "welcome",
                  thumbImageURL: "testThumbURL",
                  largeImageURL: "testLargeURL",
                  isLiked: true),
            Photo(id: "",
                  size: .zero,
                  createdAt: .distantPast,
                  welcomeDescription: "",
                  thumbImageURL: "",
                  largeImageURL: "",
                  isLiked: false)
        ]
        
        func fetchPhotosNextPage() {
            didCallFetchPhotos = true
        }
        
        func changeLike(atIndex alteringPhotoIndex: Int, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
            if changeLikeSuccessful {
                let oldPhoto = photos[alteringPhotoIndex]
                let newPhoto = Photo(id: oldPhoto.id,
                                     size: oldPhoto.size,
                                     createdAt: oldPhoto.createdAt,
                                     welcomeDescription: oldPhoto.welcomeDescription,
                                     thumbImageURL: oldPhoto.thumbImageURL,
                                     largeImageURL: oldPhoto.largeImageURL,
                                     isLiked: isLike)
                photos[alteringPhotoIndex] = newPhoto
                completion(.success(()))
            } else {
                completion(.failure(TestError.testError))
            }
        }
        
    }
    
    enum TestError: Error {
        case testError
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
    
    func testCellViewModel() {
        // given
        let imagesListService = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        
        // when
        let viewModel = presenter.cellViewModel(for: 0)
        
        // then
        XCTAssertEqual(viewModel.dateString, "17 апреля 2025 г.")
        XCTAssertEqual(viewModel.imageURL, URL(string: "testThumbURL"))
        XCTAssertEqual(viewModel.isLiked, true)
    }
    
    func testImageSize() {
        // given
        let imagesListService = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        
        // when
        let imageSize = presenter.imageSize(at: 0)
        
        // then
        XCTAssertEqual(imageSize, CGSize(width: 10, height: 10))
    }
    
    func testLikeButtonTappedSuccess() {
        // given
        let imagesListService = ImagesListServiceMock()
        imagesListService.changeLikeSuccessful = true
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let imagesListVC = ImagesListViewControllerSpy()
        imagesListVC.injectPresenter(presenter)
        
        // when
        presenter.likeButtonTapped(cell: ImagesListCell(), index: 0)
        
        // then
        XCTAssertTrue(imagesListVC.didCallSetCellLiked)
        XCTAssertEqual(imagesListVC.didSetCellToLike, false)
    }
    
    func testLikeButtonDoubleTappedSuccess() {
        // given
        let imagesListService = ImagesListServiceMock()
        imagesListService.changeLikeSuccessful = true
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let imagesListVC = ImagesListViewControllerSpy()
        imagesListVC.injectPresenter(presenter)
        
        // when
        presenter.likeButtonTapped(cell: ImagesListCell(), index: 0)
        presenter.likeButtonTapped(cell: ImagesListCell(), index: 0)
        
        // then
        XCTAssertTrue(imagesListVC.didCallSetCellLiked)
        XCTAssertEqual(imagesListVC.didSetCellToLike, true)
    }
    
    func testLikeButtonTappedFailure() {
        // given
        let imagesListService = ImagesListServiceMock()
        imagesListService.changeLikeSuccessful = false
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let imagesListVC = ImagesListViewControllerSpy()
        imagesListVC.injectPresenter(presenter)
        
        // when
        presenter.likeButtonTapped(cell: ImagesListCell(), index: 0)
        
        // then
        XCTAssertTrue(imagesListVC.didCallShowLikeErrorAlert)
    }
    
    func testCellTapped() {
        // given
        let imagesListService = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let imagesListVC = ImagesListViewControllerSpy()
        imagesListVC.injectPresenter(presenter)
        
        // when
        presenter.cellTapped(at: 0)
        
        // then
        XCTAssertTrue(imagesListVC.didCallShowSingleImageViewController)
        XCTAssertEqual(imagesListVC.urlOfSingleImageViewController, URL(string: "testLargeURL"))
    }
    
    func testDidScrollToBottom() {
        // given
        let imagesListService = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let imagesListVC = ImagesListViewControllerSpy()
        imagesListVC.injectPresenter(presenter)
        
        // when
        presenter.didScrollToBottom()
        
        // then
        XCTAssertTrue(imagesListService.didCallFetchPhotos)
    }
    
}
