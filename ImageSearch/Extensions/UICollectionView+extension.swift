//
//  UICollectionView+extension.swift
//  ImageSearch
//
//

import Foundation
import UIKit

extension UICollectionView {
    func dequeueCell<T: DequeableCollectionViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T? {
        if let cell = self.dequeueReusableCell(
            withReuseIdentifier: type.kCellIdentifier,
            for: indexPath
        ) as? T {
            return cell
        } else {
            return nil
        }
    }
}
