// 
//  SelfSizingCollectionView.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

class SelfSizingCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return self.collectionViewLayout.collectionViewContentSize
    }
}
