//
//  ImageCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class RelatedImagesCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "RelatedImagesCollectionViewCell"

    var model: Model? {
        didSet {
            accessibilityValue = model?.imageURL?.absoluteString
            imageView.kf.setImage(
                with: model?.imageURL,
                placeholder: GlobalConstants.placeholderImage
            )
        }
    }

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

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
        // imageView
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Model

extension RelatedImagesCollectionViewCell {
    struct Model {
        let imageURL: URL?
    }
}
