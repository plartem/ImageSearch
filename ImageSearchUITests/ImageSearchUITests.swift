//
//  ImageSearchUITests.swift
//  ImageSearchUITests
//
//

import XCTest

class ImageSearchUITests: XCTestCase {
    func testSearchField() throws {
        let app = XCUIApplication()
        app.launch()

        let mainSearchTextField = app.textFields["mainViewSearchTextField"]
        let searchButton = app.buttons.containing(.staticText, identifier: "Search").element
        mainSearchTextField.tap()
        mainSearchTextField.typeText("1\n")

        let searchTextField = app.textFields["searchTextField"]
        XCTAssertEqual(searchTextField.value as? String, "1")
        searchTextField.tap()
        searchTextField.typeText("2\n")
        app.buttons["Reply"].tap()

        XCTAssertEqual(mainSearchTextField.value as? String, "12")

        searchButton.tap()
        app.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 1).tap()

        XCTAssertEqual(searchTextField.value as? String, "12")
        searchTextField.tap()
        searchTextField.typeText("3\n")
        XCTAssertEqual(searchTextField.value as? String, "123")

        app.buttons["Reply"].tap()
        XCTAssertEqual(mainSearchTextField.value as? String, "123")
    }

    func testSearchTags() throws {
        let app = XCUIApplication()
        app.launch()
        let searchButton = app.buttons.containing(.staticText, identifier: "Search").element
        searchButton.tap()

        let infoCell = app.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 0)
        infoCell.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 1).tap()

        let searchTextField = app.textFields["searchTextField"]
        XCTAssertNotEqual(searchTextField.value as? String, "")
    }

    func testImageDetailRelatedImages() throws {
        let app = XCUIApplication()
        app.launch()

        let searchButton = app.buttons.containing(.staticText, identifier: "Search").element
        searchButton.tap()
        app.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 1).tap()

        let relatedImage = app.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 0)
        let newSelectedImageUrl = relatedImage.value

        app.collectionViews.firstMatch.children(matching: .cell).element(boundBy: 0).tap()

        XCTAssertEqual(app.images.firstMatch.value as? String, newSelectedImageUrl as? String)
    }
}
