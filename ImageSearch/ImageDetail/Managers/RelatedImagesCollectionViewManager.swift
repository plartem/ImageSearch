//
//  RelatedImagesCollectionViewManager.swift
//  ImageSearch
//
//

import Foundation
import UIKit

protocol RelatedImagesCollectionViewManagerDelegate: AnyObject {
    func relatedImagesCollectionViewManager(
        _ relatedImagesCollectionViewManager: RelatedImagesCollectionViewManager,
        didSelectImage image: ImageDomainModel
    )
}

class RelatedImagesCollectionViewManager: NSObject {
    // MARK: - Properties

    weak var collectionView: UICollectionView? {
        didSet {
            guard let cView = collectionView else { return }
            cView.dataSource = self
            cView.delegate = self

            cView.backgroundColor = GlobalConstants.contentBackgroundColor
            cView.isScrollEnabled = false

            cView.register(
                RelatedImagesCollectionViewCell.self,
                forCellWithReuseIdentifier: RelatedImagesCollectionViewCell.kCellIdentifier
            )
            cView.register(
                UICollectionViewCell.self,
                forCellWithReuseIdentifier: kDefaultCollectionViewCellIdentifier
            )

            reloadData()
        }
    }

    weak var delegate: RelatedImagesCollectionViewManagerDelegate?

    var model: [ImageDomainModel] = [] {
        didSet {
            guard model != oldValue else { return }
            reloadData()
        }
    }

    private var imagesPerLine: Int = 1 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.collectionViewLayout.invalidateLayout()
                self?.collectionView?.invalidateIntrinsicContentSize()
            }
        }
    }

    // MARK: - Methods

    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
            self?.collectionView?.invalidateIntrinsicContentSize()
        }
    }

    func changedOrientation(to orientation: UIInterfaceOrientation) {
        imagesPerLine = orientation.isLandscape
            ? Constants.ImagesPerLine.ladscapeMode
            : Constants.ImagesPerLine.portraitMode
    }
}

// MARK: - CollectionViewDelegate

extension RelatedImagesCollectionViewManager: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = model[safe: indexPath.row] else { return }
        delegate?.relatedImagesCollectionViewManager(self, didSelectImage: image)
    }
}

// MARK: - CollectionViewDataSource

extension RelatedImagesCollectionViewManager: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueCell(withType: RelatedImagesCollectionViewCell.self, for: indexPath) {
            cell.model = .init(imageURL: model[safe: indexPath.row]?.url)
            return cell
        }
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: kDefaultCollectionViewCellIdentifier,
            for: indexPath
        )
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return model.count
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        var space: CGFloat = 0.0

        let imagesPerLine = CGFloat(imagesPerLine)
        if let flowlayout = layout as? UICollectionViewFlowLayout {
            space = flowlayout.minimumInteritemSpacing * (imagesPerLine - 1.0)
                + flowlayout.sectionInset.left + flowlayout.sectionInset.right
        }
        let layoutWidth: CGFloat = (collectionView.frame.size.width - space) / imagesPerLine
        return CGSize(width: layoutWidth, height: layoutWidth * GlobalConstants.defaultImageHeightMultiplier)
    }
}

// MARK: - Models

extension RelatedImagesCollectionViewManager {
    private enum Constants {
        enum ImagesPerLine {
            static let portraitMode: Int = 2
            static let ladscapeMode: Int = 3
        }
    }
}
