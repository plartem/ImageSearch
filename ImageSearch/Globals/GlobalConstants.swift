//
//  GlobalConstants.swift
//  ImageSearch
//
//

import Foundation
import UIKit

let kDefaultCollectionReusableViewIdentifier = "DefaultCollectionReusableViewIdentifier"
let kDefaultCollectionViewCellIdentifier = "DefaultCollectionViewCellIdentifier"
let kDefaultTableViewCellIdentifier = "DefaultTableViewCellIdentifier"

enum GlobalConstants {
    static let pixabayLink = "https://pixabay.com/"
    static let viewSpacing: CGFloat = 16.0
    static let backgroundColor = UIColor.white
    static let placeholderImage = UIImage(named: "image_placeholder")
    static let contentBackgroundColor = UIColor(red: 0.967, green: 0.967, blue: 0.967, alpha: 1)
    static let defaultImageHeightMultiplier: CGFloat = 0.7
    enum TextField {
        static let xOffset: CGFloat = 10.0
        static let yOffset: CGFloat = 15.0
    }
    enum CroppedImageSavedDialog {
            static let title = "Image saved to album"
            static let buttonText = "Ok"
    }
    enum Errors {
        static let title = "Error"
        static let buttonText = "Ok"
        static let viewPresentingError = "View presenting error"
        static let photosNotAuthorizedError = "Application can't access Photo Library"
    }
}
