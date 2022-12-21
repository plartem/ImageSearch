//
//  ScalableImageView.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

protocol ScalableImageViewDelegate: AnyObject {
    func didTapCropButton()
}

class ScalableImageView: UIView {
    // MARK: - Properties

    var model: Model? {
        didSet {
            scaleSlider.value = 1.0
            imageScrollView.zoomScale = 1.0
            imageView.accessibilityValue = model?.imageURL?.absoluteString
            imageView.kf.setImage(
                with: model?.imageURL,
                placeholder: GlobalConstants.placeholderImage
            )
        }
    }

    weak var delegate: ScalableImageViewDelegate?

    // MARK: UI

    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = Constants.minimumZoom
        scrollView.maximumZoomScale = Constants.maximumZoom
        scrollView.bounces = false
        return scrollView
    }()
    private let contentView = UIView()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let scaleButton: UIButton = {
        let button = UIButton(configuration: Constants.ZoomButton.configuration)
        return button
    }()
    private lazy var scaleSlider: UISlider = {
        let slider = UISlider()
        slider.isHidden = true
        slider.minimumValue = Float(Constants.minimumZoom)
        slider.maximumValue = Float(Constants.maximumZoom)
        slider.value = 1.0
        slider.tintColor = Constants.sliderTintColor
        return slider
    }()
    private let cropButton: UIButton = {
        let button = UIButton(configuration: Constants.CropButton.configuration)
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
        imageScrollView.delegate = self

        scaleSlider.addTarget(self, action: #selector(scaleSliderValueChanged), for: .valueChanged)
        scaleButton.addTarget(self, action: #selector(scaleButtonTapped), for: .touchUpInside)

        cropButton.addTarget(self, action: #selector(cropButtonTapped), for: .touchUpInside)
    }

    private func buildUI() {
        // imageScrollView
        addSubview(imageScrollView)
        imageScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // contentView
        imageScrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(imageScrollView.frameLayoutGuide)
            make.height.equalTo(imageScrollView.frameLayoutGuide)
        }
        // imageView
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        // scaleSlider
        addSubview(scaleSlider)
        scaleSlider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview().offset(-GlobalConstants.viewSpacing)
        }
        // scaleButton
        addSubview(scaleButton)
        scaleButton.snp.makeConstraints { make in
            make.leading.equalTo(scaleSlider.snp.trailing).offset(GlobalConstants.viewSpacing)
            make.top.equalTo(scaleSlider)
            make.trailing.bottom.equalToSuperview().offset(-GlobalConstants.viewSpacing)
        }
        // scaleButton
        addSubview(cropButton)
        cropButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.equalToSuperview().offset(-GlobalConstants.viewSpacing)
            make.top.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    // MARK: - Methods

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1, execute: { [weak self] in
            self?.centerContentView()
        })
    }

    private func centerContentView() {
        let offsetX = max((imageScrollView.bounds.width - imageScrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((imageScrollView.bounds.height - imageScrollView.contentSize.height) * 0.5, 0)
        imageScrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0.0, right: 0.0)
    }

    @objc private func scaleSliderValueChanged(_ slider: UISlider) {
        imageScrollView.setZoomScale(CGFloat(slider.value), animated: true)
    }

    @objc private func scaleButtonTapped() {
        scaleSlider.isHidden.toggle()
    }

    @objc private func cropButtonTapped() {
        delegate?.didTapCropButton()
    }
}

// MARK: - UIScrollViewDelegate

extension ScalableImageView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(_: UIScrollView) {
        centerContentView()
        scaleSlider.value = Float(imageScrollView.zoomScale)
    }
}

// MARK: - Model

extension ScalableImageView {
    struct Model {
        let imageURL: URL?
    }
}

// MARK: - Constants

extension ScalableImageView {
    private enum Constants {
        static let minimumZoom: CGFloat = 0.5
        static let maximumZoom: CGFloat = 10.0
        static let sliderTintColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)
        enum ZoomButton {
            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()

                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 14.0, weight: .regular))
                config.image = UIImage(systemName: "plus.magnifyingglass", withConfiguration: imageConfig)

                config.baseForegroundColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)

                config.background.cornerRadius = 3.0
                config.background.backgroundColor = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
                config.contentInsets = NSDirectionalEdgeInsets(
                    top: 0.0,
                    leading: 5.0,
                    bottom: 0.0,
                    trailing: 5.0
                )
                config.cornerStyle = .fixed
                return config
            }()
        }
        enum CropButton {
            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()

                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 14.0, weight: .regular))
                config.image = UIImage(systemName: "crop", withConfiguration: imageConfig)

                config.baseForegroundColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)

                config.background.cornerRadius = 3.0
                config.background.backgroundColor = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
                config.contentInsets = NSDirectionalEdgeInsets(
                    top: 5.0,
                    leading: 5.0,
                    bottom: 5.0,
                    trailing: 5.0
                )
                config.cornerStyle = .fixed
                return config
            }()
        }
    }
}
