//
//  RelatedLabelCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class TitleCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "TitleCollectionViewCell"

    var model: Model? {
        didSet {
            titleLabel.attributedText = Constants.TitleLabel.attributedText(text: model?.title)
        }
    }

    // MARK: - UI

    private let titleLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Methods

    static func estimateSize(title: String) -> CGSize {
        let labelSize = Constants.TitleLabel.attributedText(text: title).size()
        return CGSize(
            width: labelSize.width,
            height: labelSize.height
        )
    }

    private func buildUI() {
        // titleLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Model

extension TitleCollectionViewCell {
    struct Model {
        let title: String
    }
}

// MARK: - Constants

extension TitleCollectionViewCell {
    private enum Constants {
        enum TitleLabel {
            static func attributedText(text: String?) -> NSAttributedString {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.08
                return NSAttributedString(
                    string: text ?? "",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 14.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.454, green: 0.454, blue: 0.454, alpha: 1),
                    ]
                )
            }
        }
    }
}
