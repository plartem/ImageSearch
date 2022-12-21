//
//  SearchTextField.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class SearchTextField: CustomTextField {
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfiguration()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultConfiguration()
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        buildUI()
    }

    private func buildUI() {
        backgroundColor = Constants.SearchTextField.background
        returnKeyType = .search
        // Search icon
        leftViewMode = .always
        let imageConfig = UIImage.SymbolConfiguration(
            font: Constants.SearchTextField.SearchIcon.font
        )
        let image = UIImage(
            systemName: Constants.SearchTextField.SearchIcon.systemName,
            withConfiguration: imageConfig
        )
        let imageView = UIImageView(image: image)
        imageView.tintColor = Constants.SearchTextField.SearchIcon.tintColor
        leftView = imageView

        attributedPlaceholder = Constants.SearchTextField.placeholderAttributedText
    }
}

extension SearchTextField {
    private enum Constants {
        enum SearchTextField {
            static let background = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
            static let placeholderAttributedText: NSAttributedString = {
                NSAttributedString(
                    string: "Search images, vectors and more",
                    attributes: [
                        .font: UIFont.main(),
                        .foregroundColor: UIColor(red: 0.454, green: 0.454, blue: 0.454, alpha: 1),
                    ]
                )
            }()
            enum SearchIcon {
                static let font = UIFont.main()
                static let systemName = "magnifyingglass"
                static let tintColor = UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1)
            }
        }
    }
}
