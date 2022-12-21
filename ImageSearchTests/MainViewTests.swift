//
//  MainViewTests.swift
//  ImageSearchTests
//
//

@testable import ImageSearch
import SnapshotTesting
import XCTest

class MainViewTests: XCTestCase {
    func testPortrait() {
        let viewController = MainViewController()
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.portrait)))
    }

    func testLandscape() {
        let viewController = MainViewController()
        assertSnapshot(matching: viewController, as: .image(on: .iPhoneX(.landscape)))
    }
}
