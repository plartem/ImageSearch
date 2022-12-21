//
//  SearchNavigationView.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class SearchNavigationView: UIView {
    // MARK: - Properties

    weak var delegate: SearchNavigationViewDelegate?

    private var searchSubmitTimer: Timer?

    // MARK: UI

    private let logoButton: UIButton = {
        let button = UIButton(configuration: Constants.LogoButton.config)
        return button
    }()
    private let searchTextField: SearchTextField = {
        let textField = SearchTextField()
        textField.accessibilityIdentifier = Constants.searchTextFieldAccessibilityIdentifier
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }()
    private let rightButton: UIButton

    // MARK: - Initialization

    init(rightButtonType type: RightButtonType = .back) {
        switch type {
        case .back: rightButton = UIButton(configuration: Constants.RightButton.backConfig)
        case .typeChange: rightButton = UIButton(configuration: Constants.RightButton.typeChangeConfig)
        }
        super.init(frame: .zero)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    deinit {
        searchSubmitTimer?.invalidate()
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        hero.id = "navigationView"
        searchTextField.delegate = self
        logoButton.addTarget(self, action: #selector(logoButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }

    private func buildUI() {
        // logoButton
        addSubview(logoButton)
        logoButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        // searchTextField
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(logoButton.snp.trailing).offset(GlobalConstants.viewSpacing)
            make.width.equalToSuperview().priority(.low)
        }
        // imageTypeChangeButton
        addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(searchTextField.snp.trailing).offset(GlobalConstants.viewSpacing)
        }
    }

    // MARK: - Methods

    func setSearchText(text: String?) {
        searchTextField.text = text
    }

    @objc private func searchSubmitTimerFired() {
        delegate?.searchNavigationView(self, didSubmitSearchTextField: searchTextField)
    }

    @objc private func logoButtonTapped() {
        delegate?.searchNavigationView(self, didTapLogoButton: logoButton)
    }

    @objc private func rightButtonTapped() {
        delegate?.searchNavigationView(self, didTapRightButton: rightButton)
    }
}

// MARK: - UITextFieldDelegate

extension SearchNavigationView: UITextFieldDelegate {
    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        searchSubmitTimer?.invalidate()
        searchSubmitTimer = Timer.scheduledTimer(
            timeInterval: Constants.searchSubmitTimerInterval,
            target: self,
            selector: #selector(searchSubmitTimerFired),
            userInfo: nil,
            repeats: false
        )
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchSubmitTimer?.invalidate()
        delegate?.searchNavigationView(self, didSubmitSearchTextField: textField)
        return true
    }
}

// MARK: - Model

extension SearchNavigationView {
    enum RightButtonType {
        case typeChange
        case back
    }
}

// MARK: - Constants

extension SearchNavigationView {
    private enum Constants {
        static let searchSubmitTimerInterval = 2.0
        static let searchTextFieldAccessibilityIdentifier = "searchTextField"
        enum LogoButton {
            static let config: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.borderless()
                var paragraphStyle = NSMutableParagraphStyle()
                buttonConfig.attributedTitle = .init(
                    NSAttributedString(
                        string: "P",
                        attributes: [
                            .font: UIFont.pattayaFont(ofSize: 32.0),
                            .foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                        ]
                    )
                )
                buttonConfig.contentInsets = NSDirectionalEdgeInsets(
                    top: 0.0,
                    leading: 16.0,
                    bottom: 0.0,
                    trailing: 16.0
                )
                buttonConfig.background.backgroundColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)
                return buttonConfig
            }()
        }
        enum RightButton {
            static let typeChangeConfig: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.bordered()
                buttonConfig.background.backgroundColor = .clear
                buttonConfig.background.strokeColor = UIColor(red: 0.887, green: 0.887, blue: 0.887, alpha: 1)
                buttonConfig.background.strokeWidth = 1.0
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 18.0, weight: .bold))
                buttonConfig.image = UIImage(systemName: "slider.horizontal.3", withConfiguration: imageConfig)?
                    .withTintColor(
                        UIColor(red: 0.454, green: 0.454, blue: 0.454, alpha: 1),
                        renderingMode: .alwaysOriginal
                    )
                return buttonConfig
            }()
            static let backConfig: UIButton.Configuration = {
                var buttonConfig = UIButton.Configuration.bordered()
                buttonConfig.background.backgroundColor = .clear
                buttonConfig.background.strokeColor = UIColor(red: 0.887, green: 0.887, blue: 0.887, alpha: 1)
                buttonConfig.background.strokeWidth = 1.0
                let imageConfig = UIImage.SymbolConfiguration(font: UIFont.main(ofSize: 18.0, weight: .bold))
                buttonConfig.image = UIImage(systemName: "arrowshape.turn.up.backward", withConfiguration: imageConfig)?
                    .withTintColor(
                        UIColor(red: 0.454, green: 0.454, blue: 0.454, alpha: 1),
                        renderingMode: .alwaysOriginal
                    )
                return buttonConfig
            }()
        }
    }
}
