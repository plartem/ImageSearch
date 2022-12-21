//
//  ImageDescriptionView.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

protocol ImageDescriptionViewDelegate: AnyObject {
    func imageDescriptionView(
        _ imageDescriptionView: ImageDescriptionView,
        didTapShareButton button: UIButton
    )
    func imageDescriptionView(
        _ imageDescriptionView: ImageDescriptionView,
        didTapDownloadButton button: UIButton
    )
}

class ImageDescriptionView: UIView {
    // MARK: - Properties

    weak var delegate: ImageDescriptionViewDelegate?

    // MARK: UI

    private let licenseTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.LicenseTitleLabel.attributedText
        return label
    }()
    private let licenseDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = Constants.LicenseDescriptionLabel.attributedText
        return label
    }()
    private let imageFormatLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.ImageFormatLabel.attributedText
        return label
    }()
    private let shareButton: UIButton = {
        let button = UIButton(configuration: Constants.ShareButton.configuration)
        return button
    }()
    private let downloadButton: UIButton = {
        let button = UIButton(configuration: Constants.DownloadButton.configuration)
        return button
    }()

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        backgroundColor = Constants.backgroundColor

        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }

    private func buildUI() {
        // licenseTitleLabel
        addSubview(licenseTitleLabel)
        licenseTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(GlobalConstants.viewSpacing)
        }
        // licenseDescriptionLabel
        addSubview(licenseDescriptionLabel)
        licenseDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.top.equalTo(licenseTitleLabel.snp.bottom).offset(Constants.LicenseDescriptionLabel.topOffset)
        }
        // imageFormatLabel
        addSubview(imageFormatLabel)
        imageFormatLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.leading.greaterThanOrEqualTo(licenseTitleLabel.snp.trailing)
            make.trailing.equalToSuperview().offset(-GlobalConstants.viewSpacing)
        }
        // shareButton
        addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(licenseTitleLabel.snp.trailing)
            make.trailing.equalToSuperview().offset(-GlobalConstants.viewSpacing)
            make.top.greaterThanOrEqualTo(imageFormatLabel.snp.bottom)
            make.bottom.equalTo(licenseDescriptionLabel.snp.bottom)
            make.width.equalTo(imageFormatLabel)
        }
        // downloadButton
        addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.trailing.equalToSuperview().offset(-GlobalConstants.viewSpacing)
            make.top.equalTo(licenseDescriptionLabel.snp.bottom).offset(Constants.DownloadButton.yOffset)
            make.bottom.equalToSuperview().offset(-Constants.DownloadButton.yOffset)
        }
    }

    // MARK: - Methods

    @objc private func shareButtonTapped(sender: UIButton) {
        delegate?.imageDescriptionView(self, didTapShareButton: sender)
    }

    @objc private func downloadButtonTapped(sender: UIButton) {
        delegate?.imageDescriptionView(self, didTapDownloadButton: sender)
    }
}

// MARK: - Constants

extension ImageDescriptionView {
    private enum Constants {
        static let backgroundColor = UIColor.white
        enum LicenseTitleLabel {
            static let attributedText: NSAttributedString = {
                NSAttributedString(
                    string: "APP License",
                    attributes: [
                        .font: UIFont.main(ofSize: 14.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1),
                    ]
                )
            }()
        }
        enum LicenseDescriptionLabel {
            static let topOffset: CGFloat = 6.0
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.15
                return NSAttributedString(
                    string: "Free for commercial use \nNo attribution required",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 14.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.454, green: 0.454, blue: 0.454, alpha: 1),
                    ]
                )
            }()
        }
        enum ImageFormatLabel {
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.15
                return NSAttributedString(
                    string: "Photo in .JPG format",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 14.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.175, green: 0.175, blue: 0.175, alpha: 1),
                    ]
                )
            }()
        }
        enum ShareButton {
            static let attributedTitle: NSAttributedString = {
                NSAttributedString(
                    string: "Share",
                    attributes: [
                        .foregroundColor: UIColor(red: 0.175, green: 0.175, blue: 0.175, alpha: 1),
                        .font: UIFont.main(ofSize: 14.0, weight: .regular),
                    ]
                )
            }()
            static let configuration: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.bordered()
                buttonConfig.attributedTitle = .init(attributedTitle)
                buttonConfig.baseForegroundColor = UIColor(red: 0.175, green: 0.175, blue: 0.175, alpha: 1)
                buttonConfig.background.backgroundColor = .clear
                buttonConfig.background.strokeColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)
                buttonConfig.cornerStyle = .small

                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 8.0, weight: .bold))
                buttonConfig.image = UIImage(named: "icon_share", in: nil, with: imageConfig)
                buttonConfig.imagePadding = 8.0

                return buttonConfig
            }()
        }
        enum DownloadButton {
            static let yOffset: CGFloat = 24.0
            static let attributedTitle: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 0.9
                return NSAttributedString(
                    string: "Download",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 18.0, weight: .semibold),
                        .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                    ]
                )
            }()
            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 16.0))
                config.image = UIImage(named: "icon_download", in: nil, with: imageConfig)
                config.imagePadding = 12.0
                config.attributedTitle = .init(attributedTitle)
                config.background.cornerRadius = 5.0
                config.background.backgroundColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)
                config.contentInsets = NSDirectionalEdgeInsets(
                    top: 15.0,
                    leading: 0.0,
                    bottom: 15.0,
                    trailing: 0.0
                )
                config.cornerStyle = .fixed
                return config
            }()
        }
    }
}
