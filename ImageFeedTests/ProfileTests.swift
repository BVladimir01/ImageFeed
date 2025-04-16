//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Vladimir on 15.04.2025.
//

@testable import ImageFeed
import XCTest


final class ProfileTests: XCTestCase {
    
    final class ProfilePresenterSpy: ProfilePresenterProtocol {
        
        var viewDidLoadCalled = false
        var logoutInitiated = false
        
        weak var view: ProfileViewControllerProtocol?
        
        func logoutTapped() {
            
        }
        
        func confirmLogout() {
            
        }
        
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
    }
    
    final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
        
        var didCallShowLogoutAlert = false
        var didCallSetProfileImage = false
        var presenter: ProfilePresenterProtocol?
        
        func showLogoutAlert() {
            didCallShowLogoutAlert = true
        }
        
        func setProfileDetails(profile: ImageFeed.Profile) {
            
        }
        
        func setProfileImage(url: URL) {
            didCallSetProfileImage = true
        }

    }
    
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
        let presenter = ProfilePresenter()
        let profileVCSpy = ProfileViewControllerSpy()
        profileVCSpy.injectPresenter(presenter)
        
        //when
        presenter.logoutTapped()
        
        //then
        XCTAssertTrue(profileVCSpy.didCallShowLogoutAlert)
    }
    
    
    // can not test ProfileViewController.setProfileDetails
    // no access to text of labels
    // will probably test in UI tests
    
    // can not test ProfileViewController.SetProfileImage
    // no access to profile image
    // will probably test in UI tests
    
    func testConfirmLogout() {
        // given
        let presenter = ProfilePresenter()
        OAuth2TokenStorage.shared.token = "testToken"
        
        // when
        presenter.confirmLogout()
        
        // then
        XCTAssertNil(OAuth2TokenStorage.shared.token)
        XCTAssertNil(ProfileService.shared.profile)
        XCTAssertNil(ProfileImageService.shared.avatarURL)
        XCTAssertTrue(ImagesListService.shared.photos.isEmpty)
        // critical part of logout that does not involve UI
        // does not seem to be a valid test, services contain info
        // only after real session
    }
    
    // for proper testing of presenter and VC
    // all services should be conforming protocols
    // all services should be injected as dependancies
    // not shared among all classes
    // then stubs could be used for testing
    
}
