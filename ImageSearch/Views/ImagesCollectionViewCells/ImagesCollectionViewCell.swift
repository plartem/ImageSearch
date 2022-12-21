//
//  ImagesCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import Kingfisher
import SnapKit
import UIKit

protocol ImagesCollectionViewCellDelegate: AnyObject {
    func imageCollectionViewCell(
        _ imageCollectionViewCell: ImagesCollectionViewCell,
        didTapShareButton button: UIButton
    )
}

class ImagesCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "ImagesCollectionViewCell"

    var model: Model? {
        didSet {
            switch model {
            case let .image(image):
                imageView.image = image ?? GlobalConstants.placeholderImage
            case let .url(url):
                imageView.kf.setImage(
                    with: url,
                    placeholder: GlobalConstants.placeholderImage
                )

            case .none:
                imageView.image = GlobalConstants.placeholderImage
            }
        }
    }

    weak var delegate: ImagesCollectionViewCellDelegate?

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton(configuration: Constants.ShareButton.configuration)

        button.layer.shadowColor = Constants.ShareButton.shadowColor.cgColor
        button.layer.shadowOpacity = Constants.ShareButton.shadowOpacity
        button.layer.shadowOffset = Constants.ShareButton.shadowOffset
        button.layer.shadowRadius = Constants.ShareButton.shadowRadius
        button.layer.masksToBounds = false

        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        return button
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
        // shareButton
        contentView.addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(imageView)
            make.trailing.equalTo(imageView).offset(-GlobalConstants.viewSpacing)
            make.top.equalTo(imageView).offset(GlobalConstants.viewSpacing)
            make.bottom.lessThanOrEqualTo(imageView)
        }
    }

    // MARK: - Methods

    @objc private func shareButtonTapped(_ button: UIButton) {
        delegate?.imageCollectionViewCell(self, didTapShareButton: button)
    }
}

// MARK: - Model

extension ImagesCollectionViewCell {
    enum Model: Equatable {
        case url(URL?)
        case image(UIImage?)
    }
}

// MARK: - Constants

extension ImagesCollectionViewCell {
    private enum Constants {
        static let imageCornerRadius: CGFloat = 5.0

        enum ShareButton {
            static let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            static let shadowOpacity: Float = 1.0
            static let shadowOffset = CGSize(width: 0, height: 4)
            static let shadowRadius: CGFloat = 4.0

            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()

                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 10.0, weight: .bold))

                config.image = UIImage(named: "icon_share", in: nil, with: imageConfig)?
                    .withRenderingMode(.alwaysTemplate)
                config.baseForegroundColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)

                config.background.cornerRadius = 3.0
                config.background.backgroundColor = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
                config.contentInsets = NSDirectionalEdgeInsets(
                    top: 8.0,
                    leading: 8.0,
                    bottom: 8.0,
                    trailing: 8.0
                )
                config.cornerStyle = .fixed
                return config
            }()
        }
    }
}
