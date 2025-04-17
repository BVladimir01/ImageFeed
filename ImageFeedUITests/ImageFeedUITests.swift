//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Vladimir on 17.04.2025.
//

import XCTest
@testable import SwiftKeychainWrapper


final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("--uitest-reset-token")
        app.launch()
    }
    
    func testAuth() throws {
        sleep(5)
        app.buttons["Authenticate"].tap()
        sleep(5)
        let webView = app.webViews["UnsplashWebView"]
        let loginTextField = webView.descendants(matching: .textField).element
        _ = loginTextField.waitForExistence(timeout: 3)
        loginTextField.tap()
        sleep(1)
        loginTextField.typeText("")
        sleep(1)
        app.buttons["Done"].tap()
        sleep(1)
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        _ = passwordTextField.waitForExistence(timeout: 3)
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("")
        sleep(1)
        app.buttons["Done"].tap()
        sleep(1)
        webView.buttons["Login"].tap()
        sleep(5)
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        sleep(5)
        if app.buttons["Authenticate"].exists {
            try testAuth()
        }
        app.swipeUp()
        sleep(2)
        app.swipeDown()
        sleep(2)
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        _ = firstCell.waitForExistence(timeout: 5)
        let singleImage = app.scrollViews.images.element(boundBy: 0)
        _ = singleImage.waitForExistence(timeout: 5)
        firstCell.buttons["LikeButton"].tap()
        sleep(2)
        firstCell.buttons["LikeButton"].tap()
        sleep(2)
        firstCell.tap()
        sleep(5)
        singleImage.pinch(withScale: 3, velocity: 1)
        sleep(1)
        singleImage.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        app.buttons["BackButton"].tap()
        sleep(2)
    }

    func testProfile() throws {
        sleep(5)
        if app.buttons["Authenticate"].exists {
            try testAuth()
        }
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)
        let nameLabel = app.staticTexts["NameLabel"]
        _ = nameLabel.waitForExistence(timeout: 2)
        XCTAssertEqual(nameLabel.label, "Name")
        let tagLabel = app.staticTexts["TagLabel"]
        _ = tagLabel.waitForExistence(timeout: 2)
        XCTAssertEqual(tagLabel.label, "@Tag")
        let descriptionLabel = app.staticTexts["ProfileDescriptionLabel"]
        _ = descriptionLabel.waitForExistence(timeout: 2)
        XCTAssertEqual(descriptionLabel.label, "ProfileDescription")
        sleep(1)
        app.buttons["LogoutButton"].tap()
        let alert = app.alerts.element
        XCTAssertEqual(alert.label, "Пока, пока!")
    }
    
}
