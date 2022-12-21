//
//  SearchNetworkManagerTests.swift
//  ImageSearchTests
//
//

@testable import ImageSearch
import XCTest
import RxSwift

class SearchNetworkManagerTests: XCTestCase {
    private let networkManager = SearchNetworkManager()
    private let disposeBag = DisposeBag()

    func testFetchWithoutParameters() {
        let expectation = expectation(description: "testFetchWithoutSearchTerm")
        networkManager
            .fetchImages()
            .subscribe(
                onNext: { _ in
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }

    func testFetchWithImagesPerPage1() {
        let expectation = expectation(description: "testFetchWithImagesPerPage1")
        networkManager
            .fetchImages(
                searchTerm: "",
                imageType: .all,
                page: 1,
                imagesPerPage: 20
            )
            .subscribe(
                onNext: { result in
                    XCTAssertEqual(result.hits.count, 20)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }

    func testFetchWithImagesPerPage2() {
        let expectation = expectation(description: "testFetchWithImagesPerPage2")
        networkManager
            .fetchImages(
                searchTerm: "",
                imageType: .all,
                page: 1,
                imagesPerPage: 10
            )
            .subscribe(
                onNext: { result in
                    XCTAssertEqual(result.hits.count, 10)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }

    func testFetchWithImagesPerPage3() {
        let expectation = expectation(description: "testFetchWithImagesPerPage3")
        networkManager
            .fetchImages(
                searchTerm: "",
                imageType: .all,
                page: 1,
                imagesPerPage: 5
            )
            .subscribe(
                onNext: { result in
                    XCTAssertEqual(result.hits.count, 5)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }

    func testFetchWithPhotoType() {
        let expectation = expectation(description: "testFetchWithPhotoType")
        networkManager
            .fetchImages(
                searchTerm: "",
                imageType: .photo
            )
            .subscribe(
                onNext: { result in
                    result.hits.forEach({
                        XCTAssertEqual($0.type, "photo")
                    })
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }

    func testFetchWithVectorType() {
        let expectation = expectation(description: "testFetchWithVectorType")
        networkManager
            .fetchImages(
                searchTerm: "",
                imageType: .vector
            )
            .subscribe(
                onNext: { result in
                    result.hits.forEach({
                        XCTAssertTrue($0.type.starts(with: "vector/"))
                    })
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        waitForExpectations(timeout: Constants.defaultExpectationTimeout)
    }
}

extension SearchNetworkManagerTests {
    enum Constants {
        static let defaultExpectationTimeout: Double = 10.0
    }
}
