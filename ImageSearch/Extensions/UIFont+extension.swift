//
//  UIFont+extension.swift
//  ImageSearch
//
//

import Foundation
import UIKit

extension UIFont {
    static func main(ofSize size: CGFloat = 14.0, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .semibold:
            fontName = "OpenSans-SemiBold"
        case .regular:
            fontName = "OpenSans-Regular"
        case .bold:
            fontName = "OpenSans-Bold"
        case .heavy:
            fontName = "OpenSans-ExtraBold"
        case .light:
            fontName = "OpenSans-Light"
        case .medium:
            fontName = "OpenSans-Medium"
        default:
            fontName = ""
        }
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    static func pattayaFont(ofSize size: CGFloat = 14.0) -> UIFont {
        return UIFont(name: "Pattaya-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
