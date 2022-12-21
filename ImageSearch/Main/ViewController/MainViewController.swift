//
//  MainViewController.swift
//  ImageSearch
//
//

import Foundation
import RxSwift
import SnapKit
import SwiftyMenu
import UIKit

class MainViewController: UIViewController {
    // MARK: - Properties

    private let searchTypes = [
        ImageTypeDomainModel.all,
        ImageTypeDomainModel.photo,
        ImageTypeDomainModel.illustration,
        ImageTypeDomainModel.vector,
    ]
    private let viewModel = MainViewModel()

    private let disposeBag = DisposeBag()

    // MARK: - UI

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: Constants.BackgroundView.image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = Constants.BackgroundView.colorOpacity
        return imageView
    }()
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.TitleLabel.attributedText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    private let searchTypeDropDownView = SearchFieldRightView()
    private lazy var searchTypeDropDown: SwiftyMenu = {
        let dropDown = SwiftyMenu()
        dropDown.items = searchTypes
        dropDown.configure(with: Constants.SearchTypeDropDown.attributes)
        return dropDown
    }()
    private lazy var searchTextField: SearchTextField = {
        let textField = SearchTextField()
        textField.accessibilityIdentifier = Constants.SearchTextField.accessibilityIdentifier
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.rightViewMode = .always
        textField.rightView = searchTypeDropDownView
        // add rightView to view hierarchy
        textField.setNeedsLayout()
        textField.layoutIfNeeded()

        textField.delegate = self

        return textField
    }()
    private let searchButton: UIButton = {
        let button = UIButton(configuration: Constants.SearchButton.configuration)
        return button
    }()
    private let localImagesButton: UIButton = {
        let button = UIButton(configuration: Constants.LocalImagesButton.configuration)
        return button
    }()
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.CopyrightLabel.attributedText
        return label
    }()

    // MARK: - Lifecycle

    override func loadView() {
        view = buildView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        defaultConfiguration()
    }

    // MARK: Configurations

    private func buildView() -> UIView {
        let view = UIView()

        // backgroundImageView
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // contentView
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).offset(GlobalConstants.viewSpacing)
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-GlobalConstants.viewSpacing)
        }
        // titleLabel
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.TitleLabel.topOffset)
            make.leading.trailing.equalToSuperview()
        }
        // searchTextField
        contentView.addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.SearchTextField.topOffset).priority(.low)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.width.equalTo(Constants.SearchTextField.maxWidth).priority(.medium)
            make.centerX.equalToSuperview()
        }
        // searchButton
        contentView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(Constants.SearchButton.topOffset)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.width.equalTo(Constants.SearchButton.maxWidth).priority(.medium)
            make.centerX.equalToSuperview()
        }
        // localImagesButton
        contentView.addSubview(localImagesButton)
        localImagesButton.snp.makeConstraints { make in
            make.top.equalTo(searchButton.snp.bottom).offset(Constants.LocalImagesButton.topOffset)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.width.equalTo(Constants.SearchButton.maxWidth).priority(.medium)
            make.centerX.equalToSuperview()
        }
        // copyrightLabel
        contentView.addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(localImagesButton.snp.bottom).offset(Constants.CopyrightLabel.topOffset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        // searchTypeDropDown
        view.addSubview(searchTypeDropDown)
        searchTypeDropDown.heightConstraint = NSLayoutConstraint(
            item: searchTypeDropDown,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: Constants.SearchTypeDropDown.height
        )
        searchTypeDropDown.heightConstraint.isActive = true
        searchTypeDropDown.snp.makeConstraints { make in
            make.top.equalTo(searchTextField).offset(Constants.SearchTypeDropDown.topOffset)
            make.leading.trailing.equalTo(searchTypeDropDownView)
            make.bottom.lessThanOrEqualToSuperview()
        }

        return view
    }

    private func defaultConfiguration() {
        view.backgroundColor = Constants.backgroundColor

        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        localImagesButton.addTarget(self, action: #selector(localImagesButtonTapped), for: .touchUpInside)

        hideKeyboardOnTappedAround()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.searchTypeDropDown.selectedIndex = 0
        }
    }

    // MARK: - Methods

    @objc private func searchButtonTapped() {
        viewModel.onSearchButtonTapped(
            searchTerm: searchTextField.text,
            imageType: searchTypes[safe: searchTypeDropDown.selectedIndex ?? 0] ?? .all
        )
    }

    @objc private func localImagesButtonTapped() {
        viewModel.onLocalImagesButtonTapped()
    }
}

// MARK: - RX -

extension MainViewController {
    private func subscribe() {
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        viewModel.model
            .subscribe(onNext: { [weak self] model in
                DispatchQueue.main.async {
                    self?.searchTextField.text = model.searchTerm
                }
            })
            .disposed(by: disposeBag)
        viewModel.showSearchScreen
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let searchViewModel = SearchViewModel()
                    searchViewModel.delegate = self.viewModel
                    let viewController = SearchViewController(viewModel: searchViewModel)
                    self.pushOrPresent(viewController)
                }
            })
            .disposed(by: disposeBag)
        viewModel.showLocalImagesScreen
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let viewController = LocalImagesViewController()
                    self.pushOrPresent(viewController)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        viewModel.onSearchSubmitted(
            searchTerm: searchTextField.text,
            imageType: searchTypes[safe: searchTypeDropDown.selectedIndex ?? 0] ?? .all
        )
        return true
    }
}

// MARK: - Constants

extension MainViewController {
    private enum Constants {
        static let backgroundColor = UIColor.black
        enum BackgroundView {
            static let image = UIImage(named: "background")
            static let colorOpacity: Float = 0.55
        }
        enum SearchTypes {
            static let image = "Images"
            static let video = "Videos"
        }
        enum TitleLabel {
            static let topOffset: CGFloat = 50.0
            static let attributedText: NSAttributedString = {
                NSAttributedString(
                    string: "Zabierz swoich odbiorców na wizualną przygodę",
                    attributes: [
                        .font: UIFont.main(ofSize: 26.0, weight: .heavy),
                        .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                    ]
                )
            }()
        }
        enum SearchTextField {
            static let accessibilityIdentifier = "mainViewSearchTextField"
            static let topOffset: CGFloat = 60.0
            static let maxWidth: CGFloat = 340.0
        }
        enum SearchTypeDropDown {
            static let topOffset: CGFloat = 8.0
            static let height: CGFloat = 34.0
            static let backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
            static let animationDuration: CGFloat = 0.3
            static let attributes: SwiftyMenuAttributes = {
                var attributes = SwiftyMenuAttributes()

                // Custom Behavior
                attributes.multiSelect = .disabled

                // Custom UI
                attributes.roundCorners = .all(radius: 5)
                attributes.rowStyle = .value(
                    height: 40,
                    backgroundColor: backgroundColor,
                    selectedColor: backgroundColor
                )
                attributes.headerStyle = .value(backgroundColor: .clear, height: Int(height))
                attributes.textStyle = .value(color: .gray, separator: ", ", font: UIFont.main())
                attributes.arrowStyle = .value(isEnabled: true)
                attributes.accessory = .disabled
                attributes.separatorStyle = .value(color: .gray, isBlured: false, style: .singleLine)
                // Custom Animations
                attributes.expandingAnimation = .linear
                attributes.expandingTiming = .value(duration: 0.5, delay: 0)

                attributes.collapsingAnimation = .linear
                attributes.collapsingTiming = .value(duration: 0.5, delay: 0)

                return attributes
            }()
        }
        enum SearchButton {
            static let topOffset: CGFloat = 16.0
            static let maxWidth: CGFloat = 340.0
            static let attributedTitle: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 0.9
                return NSAttributedString(
                    string: "Search",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 18.0, weight: .semibold),
                        .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                    ]
                )
            }()
            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 12.0))
                config.image = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
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
        enum LocalImagesButton {
            static let topOffset: CGFloat = 16.0
            static let maxWidth: CGFloat = 340.0
            static let attributedTitle: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 0.9
                return NSAttributedString(
                    string: "Local images",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 18.0, weight: .semibold),
                        .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                    ]
                )
            }()
            static let configuration: UIButton.Configuration = {
                var config = UIButton.Configuration.filled()
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 12.0))
                config.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: imageConfig)
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
        enum CopyrightLabel {
            static let topOffset: CGFloat = 16.0
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.35
                paragraphStyle.alignment = .center
                return NSAttributedString(
                    string: "Photo by Free-Photos",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 12.0, weight: .regular),
                        .foregroundColor: UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1),
                    ]
                )
            }()
        }
    }
}
