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
    
}
