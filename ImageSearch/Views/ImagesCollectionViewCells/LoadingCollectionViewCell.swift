//
//  LoadingCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import Kingfisher
import SnapKit
import UIKit

class LoadingCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "LoadingCollectionViewCell"

    // MARK: - UI

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: Configurations

    private func buildUI() {
        // activityIndicator
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview()
            make.top.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - Methods

    func startSpinning() {
        activityIndicator.startAnimating()
    }
}
