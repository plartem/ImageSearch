//
//  ImagesCollectionViewManager.swift
//  ImageSearch
//
//

import Foundation
import Hero
import UIKit

protocol ImagesCollectionViewManagerDelegate: AnyObject {
    func imagesCollectionViewManager(
        _ imagesCollectionViewManager: ImagesCollectionViewManager,
        didSelectImage image: ImagesCollectionViewManager.ImageModel
    )

    func imagesCollectionViewManager(
        _ imagesCollectionViewManager: ImagesCollectionViewManager,
        didTapShareButtonForImage image: ImagesCollectionViewManager.ImageModel
    )

    func imagesCollectionViewManager(
        _ imagesCollectionViewManager: ImagesCollectionViewManager,
        didTapTag tag: String
    )

    func imagesCollectionViewManager(
        _ imagesCollectionViewManager: ImagesCollectionViewManager,
        didTriggerRefresh collectionView: UICollectionView?
    )

    func imagesCollectionViewManager(
        _ imagesCollectionViewManager: ImagesCollectionViewManager,
        didTriggerLoadMore collectionView: UICollectionView?
    )
}

class ImagesCollectionViewManager: NSObject {
    // MARK: - Properties

    weak var collectionView: UICollectionView? {
        didSet {
            guard let cView = collectionView else { return }

            cView.dataSource = self
            cView.delegate = self
            cView.backgroundColor = GlobalConstants.contentBackgroundColor

            cView.refreshControl = UIRefreshControl()
            cView.refreshControl?.addTarget(
                self,
                action: #selector(imagesRefreshControlTriggered),
                for: .valueChanged
            )
            cView.bottomRefreshControl = UIRefreshControl()
            cView.bottomRefreshControl?.addTarget(
                self,
                action: #selector(imagesBottomRefreshControlTriggered),
                for: .valueChanged
            )

            cView.register(
                InfoImagesCollectionViewCell.self,
                forCellWithReuseIdentifier: InfoImagesCollectionViewCell.kCellIdentifier
            )
            cView.register(
                ImagesCollectionViewCell.self,
                forCellWithReuseIdentifier: ImagesCollectionViewCell.kCellIdentifier
            )
            cView.register(
                LoadingCollectionViewCell.self,
                forCellWithReuseIdentifier: LoadingCollectionViewCell.kCellIdentifier
            )
            cView.register(
                UICollectionViewCell.self,
                forCellWithReuseIdentifier: kDefaultCollectionViewCellIdentifier
            )

            DispatchQueue.main.async { [weak self] in
                self?.updateCollectionViewData()
            }
        }
    }

    weak var delegate: ImagesCollectionViewManagerDelegate?

    var dataSource: [CellData] = [.loader] {
        didSet {
            if dataSource.starts(with: oldValue, by: CellData.isSameType) {
                let updateIndexPaths = (0 ..< oldValue.count)
                    .filter({ dataSource[$0] != oldValue[$0] })
                    .map({ IndexPath(row: $0, section: 0) })
                let insertedIndexPaths = (oldValue.count ..< dataSource.count)
                    .map({ IndexPath(row: $0, section: 0) })
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    for i in updateIndexPaths {
                        switch self.dataSource[i.row] {
                        case let .image(image):
                            if let cell = self.collectionView?.cellForItem(at: i) as? ImagesCollectionViewCell {
                                cell.model = image.image
                            }
                        case let .info(info):
                            if let cell = self.collectionView?.cellForItem(at: i) as? InfoImagesCollectionViewCell {
                                cell.model = info
                            }
                        case .loader: break
                        }
                    }
                    self.collectionView?.insertItems(at: insertedIndexPaths)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.updateCollectionViewData()
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.refreshControl?.endRefreshing()
                self?.collectionView?.bottomRefreshControl?.endRefreshing()
            }
            triggerBottomRefreshOnSrollToLast = true
        }
    }

    private var triggerBottomRefreshOnSrollToLast = false

    // MARK: - Methods

    private func updateCollectionViewData() {
        collectionView?.reloadData()
        collectionView?.setContentOffset(.zero, animated: false)
    }

    @objc private func imagesRefreshControlTriggered() {
        delegate?.imagesCollectionViewManager(self, didTriggerRefresh: collectionView)
    }

    @objc private func imagesBottomRefreshControlTriggered() {
        delegate?.imagesCollectionViewManager(self, didTriggerLoadMore: collectionView)
    }
}

// MARK: - InfoImagesCollectionViewCellDelegate

extension ImagesCollectionViewManager: InfoImagesCollectionViewCellDelegate {
    func infoImagesCollectionViewCell(_: InfoImagesCollectionViewCell, didTapTag tag: String) {
        delegate?.imagesCollectionViewManager(self, didTapTag: tag)
    }
}

// MARK: - ImagesCollectionViewCellDelegate

extension ImagesCollectionViewManager: ImagesCollectionViewCellDelegate {
    func imageCollectionViewCell(_ imageCollectionViewCell: ImagesCollectionViewCell, didTapShareButton _: UIButton) {
        guard let indexPath = collectionView?.indexPath(for: imageCollectionViewCell),
              case let .image(image) = dataSource[safe: indexPath.row] else { return }
        delegate?.imagesCollectionViewManager(self, didTapShareButtonForImage: image)
    }
}

// MARK: - UIScrollViewDelegate

extension ImagesCollectionViewManager: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_: UIScrollView) {
        if triggerBottomRefreshOnSrollToLast,
           let cView = collectionView,
           cView.indexPathsForVisibleItems.count < dataSource.count,
           cView.indexPathsForVisibleItems.contains(
               where: { $0.row == dataSource.count - 1 }
           ) == true,
           cView.bottomRefreshControl?.isRefreshing == false {
            triggerBottomRefreshOnSrollToLast = false
            cView.bottomRefreshControl?.beginRefreshing()
            delegate?.imagesCollectionViewManager(self, didTriggerLoadMore: collectionView)
        }
    }
}

// MARK: - CollectionViewDelegate

extension ImagesCollectionViewManager: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .image(image) = dataSource[safe: indexPath.row] else { return }
        delegate?.imagesCollectionViewManager(self, didSelectImage: image)
    }
}

// MARK: - CollectionViewDataSource

extension ImagesCollectionViewManager: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataSource[safe: indexPath.row] {
        case let .info(info):
            if let cell = collectionView.dequeueCell(withType: InfoImagesCollectionViewCell.self, for: indexPath) {
                cell.model = info
                cell.delegate = self
                return cell
            }

        case let .image(image):
            if let cell = collectionView.dequeueCell(withType: ImagesCollectionViewCell.self, for: indexPath) {
                cell.hero.id = "image" + String(image.id)
                cell.model = image.image
                cell.delegate = self
                return cell
            }

        case .loader:
            if let cell = collectionView.dequeueCell(withType: LoadingCollectionViewCell.self, for: indexPath) {
                cell.startSpinning()
                return cell
            }

        case .none:
            break
        }

        return collectionView.dequeueReusableCell(
            withReuseIdentifier: kDefaultCollectionViewCellIdentifier,
            for: indexPath
        )
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellData = dataSource[safe: indexPath.row] else { return .zero }
        var space: CGFloat = 0.0
        if let flowlayout = layout as? UICollectionViewFlowLayout {
            space = flowlayout.sectionInset.left + flowlayout.sectionInset.right
        }
        let layoutWidth: CGFloat = collectionView.frame.size.width - space
        switch cellData {
        case let .info(info):
            let cellHeight = InfoImagesCollectionViewCell.estimateHeight(
                data: info
            )
            return CGSize(width: layoutWidth, height: cellHeight)

        case let .image(image: image):
            let cellWidth = min(layoutWidth, image.width)
            let cellHeight = cellWidth / image.width * image.height
            return CGSize(width: cellWidth, height: cellHeight)

        case .loader:
            return CGSize(width: layoutWidth, height: layoutWidth)
        }
    }
}

// MARK: - Models

extension ImagesCollectionViewManager {
    enum CellData: Equatable {
        case info(InfoImagesCollectionViewCell.Model)
        case image(ImageModel)
        case loader

        static func isSameType(_ lValue: CellData, _ rValue: CellData) -> Bool {
            switch (lValue, rValue) {
            case (.info, .info),
                 (.image, .image),
                 (.loader, .loader):
                return true
            default:
                return false
            }
        }
    }
    struct ImageModel: Equatable {
        let id: Int
        let image: ImagesCollectionViewCell.Model
        let width: CGFloat
        let height: CGFloat
    }
}

// MARK: - Constants

extension ImagesCollectionViewManager {
    private enum Constants {
        static let headerSize: CGFloat = 70.0
    }
}
