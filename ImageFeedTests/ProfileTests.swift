//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Vladimir on 15.04.2025.
//

@testable import ImageFeed
import XCTest


final class ProfileTests: XCTestCase {
    
    // MARK: - Class Duplicates
    
    final class ProfilePresenterSpy: ProfilePresenterProtocol {
        
        var viewDidLoadCalled = false
        var logoutInitiated = false
        weak var view: ProfileViewControllerProtocol?
        
        func logoutTapped() { }
        
        func confirmLogout() { }
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
    }
    
    final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
        
        var didCallShowLogoutAlert = false
        var didCallSetProfileImage = false
        var didCallSetProfileImageExpectation: XCTestExpectation?
        var didCallSetProfileDetails = false
        var presenter: ProfilePresenterProtocol?
        
        func showLogoutAlert() {
            didCallShowLogoutAlert = true
        }
        
        func setProfileDetails(profile: ImageFeed.Profile) {
            didCallSetProfileDetails = true
        }
        
        func setProfileImage(url: URL) {
            didCallSetProfileImage = true
            didCallSetProfileImageExpectation?.fulfill()
        }

    }
    
    final class ProfileImageServiceStub: ProfileImageServiceProtocol {
        
        var fetchSuccessful = false
        var avatarURL: String?
        
        func fetchProfileImageURL(username: String, completion: @escaping (Result<String, any Error>) -> Void) { }
        
    }
    
    final class ProfileServiceStub: ProfileServiceProtocol {
        
        var fetchSuccessful = false
        var profile: Profile? = nil
        
        func fetchProfile(for token: String, completion: @escaping (Result<ImageFeed.Profile, any Error>) -> Void) { }
        
    }
    
    final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
        
        var logoutCalled = false
        weak var delegate: ProfileLogoutServiceDelegate?
        
        func logout() {
            logoutCalled = true
        }
        
        
    }
    
    // MARK: - Tests
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let presenterSpy = ProfilePresenterSpy()
        let profileVC = ProfileViewController()
        profileVC.injectPresenter(presenterSpy)
        
        //when
        _ = profileVC.view
        
        //then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCallsAlertPopup() {
        // given
        let presenter = ProfilePresenter(profileService: ProfileServiceStub(),
                                         profileImageService: ProfileImageServiceStub(),
                                         profileLogoutService: ProfileLogoutService())
        let profileVCSpy = ProfileViewControllerSpy()
        profileVCSpy.injectPresenter(presenter)
        
        //when
        presenter.logoutTapped()
        
        //then
        XCTAssertTrue(profileVCSpy.didCallShowLogoutAlert)
    }
    
    func testViewDidLoadCallSetProfile() {
        // given
        let profileService = ProfileServiceStub()
        profileService.profile = Profile(username: "", name: "", loginName: "", bio: "")
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: ProfileImageServiceStub(),
                                         profileLogoutService: ProfileLogoutService())
        let profileVCSpy = ProfileViewControllerSpy()
        profileVCSpy.injectPresenter(presenter)
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(profileVCSpy.didCallSetProfileDetails)
    }
    
    
    func testConfirmLogoutCallLogout() {
        // given
        let profileLogoutService = ProfileLogoutServiceSpy()
        let presenter = ProfilePresenter(profileService: ProfileServiceStub(),
                                         profileImageService: ProfileImageServiceStub(),
                                         profileLogoutService: profileLogoutService)
        profileLogoutService.delegate = presenter
        let profileVCSpy = ProfileViewControllerSpy()
        profileVCSpy.injectPresenter(presenter)
        
        // when
        presenter.confirmLogout()
        
        // then
        XCTAssertTrue(profileLogoutService.logoutCalled)
    }
    
    func testSetProfileImageFromViewDidLoad() {
        // given
        let profileImageService = ProfileImageServiceStub()
        profileImageService.avatarURL = "testURL"
        let profileService = ProfileServiceStub()
        profileService.profile = Profile(username: "", name: "", loginName: "", bio: "")
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: ProfileLogoutService())
        let profileVCSpy = ProfileViewControllerSpy()
        let expectation = XCTestExpectation(description: "didCallSetProfileImage")
        profileVCSpy.didCallSetProfileImageExpectation = expectation
        profileVCSpy.injectPresenter(presenter)
        
        // when
        presenter.viewDidLoad()
        
        // then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(profileVCSpy.didCallSetProfileImage)
    }
    
    func testNotificationCausesSetImage() {
        // given
        let profileImageService = ProfileImageServiceStub()
        profileImageService.avatarURL = nil
        let profileService = ProfileServiceStub()
        profileService.profile = Profile(username: "", name: "", loginName: "", bio: "")
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: ProfileLogoutService())
        let profileVCSpy = ProfileViewControllerSpy()
        let expectation = XCTestExpectation(description: "didCallSetProfileImage")
        profileVCSpy.didCallSetProfileImageExpectation = expectation
        profileVCSpy.injectPresenter(presenter)
        
        // when
        presenter.viewDidLoad()
        profileImageService.avatarURL = "testURL"
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: profileImageService)
        
        // then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(profileVCSpy.didCallSetProfileImage)
    }
    
}
