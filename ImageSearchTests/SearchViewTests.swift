//
//  SearchViewTests.swift
//  ImageSearchTests
//
//

@testable import ImageSearch
import SnapshotTesting
import XCTest

class SearchViewTests: XCTestCase {
    func testControllerPortrait() {
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(viewModel: viewModel)
        assertSnapshot(
            matching: UINavigationController(rootViewController: viewController),
            as: .image(on: .iPhoneX(.portrait))
        )
    }

    func testControllerLandscape() {
        let viewModel = SearchViewModel()
        let viewController = SearchViewController(viewModel: viewModel)
        assertSnapshot(
            matching: UINavigationController(rootViewController: viewController),
            as: .image(on: .iPhoneX(.landscape))
        )
    }

    func testImagesCollectionViewCell() {
        let view = ImagesCollectionViewCell(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 260.0))
        view.model = .init(imageURL: nil)
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testInfoImagesCollectionViewCell1() {
        let view = InfoImagesCollectionViewCell(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 70.0))
        view.model = .init(
            imagesCount: 123_456,
            tags: ["ds", "qwe", "13"]
        )
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testInfoImagesCollectionViewCell2() {
        let view = InfoImagesCollectionViewCell(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 70.0))
        view.model = .init(
            imagesCount: 123_456,
            tags: []
        )
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testInfoImagesCollectionViewCell3() {
        let view = InfoImagesCollectionViewCell(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 70.0))
        view.model = .init(
            imagesCount: 123_456,
            tags: ["ds", "qwe", "13", "qwe", "13", "qwe", "13", "qwe", "13", "qwe", "13", "qwe", "13"]
        )
        assertSnapshot(
            matching: view,
            as: .image
        )
    }
}
