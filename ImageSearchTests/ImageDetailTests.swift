//
//  ImageDetailTests.swift
//  ImageSearchTests
//
//

@testable import ImageSearch
import SnapshotTesting
import XCTest
import SnapKit

class ImageDetailTests: XCTestCase {
    func testControllerPortrait() {
        let viewModel = ImageDetailViewModel(selectedImage: .init(id: 1, url: nil, width: 375, height: 265))
        let viewController = ImageDetailViewController(viewModel: viewModel)
        assertSnapshot(
            matching: UINavigationController(rootViewController: viewController),
            as: .image(on: .iPhoneX(.portrait))
        )
    }

    func testControllerLandscape() {
        let viewModel = ImageDetailViewModel(selectedImage: .init(id: 1, url: nil, width: 375, height: 265))
        let viewController = ImageDetailViewController(viewModel: viewModel)
        assertSnapshot(
            matching: UINavigationController(rootViewController: viewController),
            as: .image(on: .iPhoneX(.landscape))
        )
    }
}
