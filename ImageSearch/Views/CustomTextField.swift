//
//  CustomTextField.swift
//  ImageSearch
//
//

import Accelerate
import Foundation
import SnapKit
import UIKit

class CustomTextField: UITextField {
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConfiguration()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultConfiguration()
    }

    // MARK: - Configurations

    private func defaultConfiguration() {
        buildUI()
        addEditingTextFieldTargets()
    }

    private func buildUI() {
        configureBorderLook()
        layer.cornerRadius = Constants.cornerRadius
        autocapitalizationType = .none
        autocorrectionType = .no
        clipsToBounds = true
        textColor = Constants.textColor
        tintColor = Constants.tintColor
        font = Constants.font
    }

    private func addEditingTextFieldTargets() {
        addTarget(self, action: #selector(editingBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
    }

    // MARK: - UI

    private func configureBorderLook() {
        borderStyle = .none
        if isEditing {
            layer.borderColor = Constants.Border.focusedColor.cgColor
            layer.borderWidth = Constants.Border.focusedWidth
        } else {
            layer.borderColor = Constants.Border.unfocusedColor.cgColor
            layer.borderWidth = Constants.Border.unfocusedWidth
        }
    }

    // MARK: - Methods

    @objc private func editingBegin(_: UITextField) {
        configureBorderLook()
    }

    @objc private func editingEnd(_: UITextField) {
        configureBorderLook()
    }
}

// MARK: - Padding

extension CustomTextField {
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let newRect = super.textRect(forBounds: bounds).inset(by: Constants.padding)
        return newRect
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let newRect = super.placeholderRect(forBounds: bounds)
        return newRect
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newRect = super.editingRect(forBounds: bounds).inset(by: Constants.padding)
        return newRect
    }

    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += GlobalConstants.TextField.xOffset
        return textRect
    }
}

// MARK: - Constants

extension CustomTextField {
    private enum Constants {
        static let cornerRadius: CGFloat = 4.0
        static let padding = UIEdgeInsets(
            top: GlobalConstants.TextField.yOffset,
            left: GlobalConstants.TextField.xOffset,
            bottom: GlobalConstants.TextField.yOffset,
            right: GlobalConstants.TextField.xOffset
        )
        static let font = UIFont.main()
        static let textColor = UIColor(red: 0.175, green: 0.175, blue: 0.175, alpha: 1)
        static let tintColor = UIColor(red: 0.175, green: 0.175, blue: 0.175, alpha: 1)
        enum Border {
            static let focusedColor = UIColor(red: 0.261, green: 0.044, blue: 0.879, alpha: 1)
            static let focusedWidth: CGFloat = 1.0
            static let unfocusedColor = UIColor(red: 0.887, green: 0.887, blue: 0.887, alpha: 0.887)
            static let unfocusedWidth: CGFloat = 1.0
        }
    }
}
