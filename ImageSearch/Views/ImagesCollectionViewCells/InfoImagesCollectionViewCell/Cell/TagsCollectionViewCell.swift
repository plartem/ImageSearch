//
//  TagsCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class TagsCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "TagsCollectionViewCell"

    var model: Model? {
        didSet {
            updateUI()
        }
    }

    // MARK: - UI

    private let tagLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: Configurations

    private func defaultConfiguration() {
        contentView.backgroundColor = Constants.backgroundColor
        contentView.layer.borderColor = Constants.borderColor.cgColor
        contentView.layer.borderWidth = Constants.borderWidh
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
    }

    // MARK: - Methods

    static func estimateSize(tag: String) -> CGSize {
        let labelSize = NSAttributedString(attributedString: Constants.labelAttributedText, newString: tag).size()
        return CGSize(
            width: labelSize.width + Constants.labelOffsetX * 2,
            height: labelSize.height + Constants.labelOffsetY * 2
        )
    }

    private func buildUI() {
        // tagLabel
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateUI() {
        guard let data = model else { return }
        tagLabel.attributedText = NSAttributedString(
            attributedString: Constants.labelAttributedText,
            newString: data.tagText
        )
    }
}

// MARK: - Model

extension TagsCollectionViewCell {
    struct Model {
        let tagText: String
    }
}

// MARK: - Constants

extension TagsCollectionViewCell {
    private enum Constants {
        static let labelOffsetX: CGFloat = 8.0
        static let labelOffsetY: CGFloat = 4.0
        static let labelAttributedText: NSAttributedString = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineHeightMultiple = 1.08
            return NSAttributedString(
                string: " ",
                attributes: [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.main(ofSize: 14.0, weight: .regular),
                ]
            )
        }()
        static let backgroundColor = UIColor(red: 0.887, green: 0.887, blue: 0.887, alpha: 1)
        static let borderColor = UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1)
        static let borderWidh: CGFloat = 1.0
        static let cornerRadius: CGFloat = 3.0
    }
}
