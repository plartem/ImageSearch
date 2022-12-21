//
//  SearchTypeDropdownView.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class SearchFieldRightView: UIView {
    // MARK: UI

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.separatorColor
        return view
    }()
    private let placeholderView = UILabel()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        buildUI()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Configurations

    private func buildUI() {
        // separatorView
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(Constants.separatorHeight)
            make.width.equalTo(Constants.separatorWidth)
        }
        // currentTypeLabel
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints { make in
            make.leading.equalTo(separatorView.snp.trailing)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(Constants.viewWidth)
        }
    }
}

// MARK: - Constants

extension SearchFieldRightView {
    private enum Constants {
        static let viewSpacing: CGFloat = 8.0
        static let separatorColor = UIColor(red: 0.825, green: 0.825, blue: 0.825, alpha: 1)
        static let separatorWidth: CGFloat = 1.0
        static let separatorHeight: CGFloat = 30.0
        static let viewWidth: CGFloat = 105.0
    }
}
