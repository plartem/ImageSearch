//
//  GlobalViewsTests.swift
//  ImageSearchTests
//
//

@testable import ImageSearch
import SnapshotTesting
import XCTest

class GlobalViewsTests: XCTestCase {
    func testSearchTextField1() {
        let view = SearchTextField(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0))
        view.text = ""
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testSearchTextField2() {
        let view = SearchTextField(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0))
        view.text = "qwef"
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testSearchTextField3() {
        let view = SearchTextField(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0))
        view.text = "Asdfafvasdgwewcvgqwxzwrqxqwrexrqwexrqwere14231234324a"
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testSearchNavigationView1() {
        let view = SearchNavigationView()
        view.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0)
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testSearchNavigationView2() {
        let view = SearchNavigationView(rightButtonType: .back)
        view.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0)
        assertSnapshot(
            matching: view,
            as: .image
        )
    }

    func testSearchNavigationView3() {
        let view = SearchNavigationView(rightButtonType: .typeChange)
        view.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0)
        assertSnapshot(
            matching: view,
            as: .image
        )
    }
}
