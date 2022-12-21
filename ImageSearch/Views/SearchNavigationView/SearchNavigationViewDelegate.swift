//
//  SearchNavigationViewDelegate.swift
//  ImageSearch
//
//

import Foundation
import UIKit

protocol SearchNavigationViewDelegate: AnyObject {
    func searchNavigationView(
        _ searchNavigationView: SearchNavigationView,
        didSubmitSearchTextField textField: UITextField
    )

    func searchNavigationView(
        _ searchNavigationView: SearchNavigationView,
        didTapLogoButton button: UIButton
    )

    func searchNavigationView(
        _ searchNavigationView: SearchNavigationView,
        didTapRightButton button: UIButton
    )
}

extension SearchNavigationViewDelegate {
    func searchNavigationView(
        _ searchNavigationView: SearchNavigationView,
        didTapLogoButton button: UIButton
    ) {
        guard let url = URL(string: GlobalConstants.pixabayLink) else { return }
        UIApplication.shared.open(url)
    }
}
