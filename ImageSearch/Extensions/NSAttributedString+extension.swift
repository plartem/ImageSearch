//
//  NSAttributedString+extension.swift
//  ImageSearch
//
//

import Foundation

extension NSAttributedString {
    convenience init(attributedString: NSAttributedString, newString string: String) {
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedText.mutableString.setString(string)
        self.init(attributedString: mutableAttributedText)
    }
}
