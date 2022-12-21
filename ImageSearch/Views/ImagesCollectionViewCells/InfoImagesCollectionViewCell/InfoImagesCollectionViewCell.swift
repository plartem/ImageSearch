//
//  InfoImagesCollectionViewCell.swift
//  ImageSearch
//
//

import Foundation
import SnapKit
import UIKit

protocol InfoImagesCollectionViewCellDelegate: AnyObject {
    func infoImagesCollectionViewCell(
        _ infoImagesCollectionViewCell: InfoImagesCollectionViewCell,
        didTapTag tag: String
    )
}

class InfoImagesCollectionViewCell: UICollectionViewCell, DequeableCollectionViewCell {
    // MARK: - Properties

    static let kCellIdentifier = "InfoImagesCollectionViewCell"

    var model: Model? {
        didSet {
            updateImagesCountLabel()
            updateTagsCollectionViewDataSource()
        }
    }

    private var tagsCollectionViewDataSource: [CellData] = [] {
        didSet {
            relatedTagsCollectionView.setContentOffset(.zero, animated: false)
            relatedTagsCollectionView.reloadData()
        }
    }

    weak var delegate: InfoImagesCollectionViewCellDelegate?

    // MARK: UI

    private let imagesCountLabel = UILabel()
    private let relatedTagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.tagsSpacing
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = .init(
            top: 0.0,
            left: GlobalConstants.viewSpacing,
            bottom: 0.0,
            right: GlobalConstants.viewSpacing
        )
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        defaultConfiguration()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    // MARK: Configurations

    private func buildUI() {
        // imagesCountLabel
        contentView.addSubview(imagesCountLabel)
        imagesCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(Constants.labelOffsetTop)
            make.trailing.equalToSuperview()
        }
        // relatedTagsStackView
        contentView.addSubview(relatedTagsCollectionView)
        relatedTagsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(imagesCountLabel.snp.bottom).offset(Constants.tagsOffsetTop)
            make.leading.equalToSuperview().offset(-GlobalConstants.viewSpacing)
            make.trailing.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.bottom.equalToSuperview()
        }
    }

    private func defaultConfiguration() {
        relatedTagsCollectionView.dataSource = self
        relatedTagsCollectionView.delegate = self

        relatedTagsCollectionView.register(
            TitleCollectionViewCell.self,
            forCellWithReuseIdentifier: TitleCollectionViewCell.kCellIdentifier
        )
        relatedTagsCollectionView.register(
            TagsCollectionViewCell.self,
            forCellWithReuseIdentifier: TagsCollectionViewCell.kCellIdentifier
        )
        relatedTagsCollectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: kDefaultCollectionViewCellIdentifier
        )

        relatedTagsCollectionView.reloadData()
    }

    // MARK: - Methods

    static func estimateHeight(data: Model) -> CGFloat {
        let imagesCountSize = Constants.ImagesCountLabel.attributedText(imagesCount: data.imagesCount).size()
        var tagSize = CGSize.zero
        if !data.tags.isEmpty, let tag = data.tags.first {
            tagSize = TagsCollectionViewCell.estimateSize(tag: tag)
        }
        return Constants.labelOffsetTop + imagesCountSize.height + tagSize.height + GlobalConstants.viewSpacing
    }

    private func updateImagesCountLabel() {
        guard let data = model else { return }
        imagesCountLabel.attributedText = Constants.ImagesCountLabel.attributedText(imagesCount: data.imagesCount)
    }

    private func updateTagsCollectionViewDataSource() {
        guard let data = model, !data.tags.isEmpty else {
            tagsCollectionViewDataSource = []
            return
        }
        tagsCollectionViewDataSource = [CellData.title(Constants.relatedTitleText)]
            + data.tags.map({ CellData.tag($0) })
    }
}

// MARK: - TagsCollectionViewDelegate

extension InfoImagesCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .tag(tag) = tagsCollectionViewDataSource[safe: indexPath.row] else { return }
        delegate?.infoImagesCollectionViewCell(self, didTapTag: tag)
    }
}

// MARK: - TagsCollectionViewDataSource

extension InfoImagesCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tagsCollectionViewDataSource[safe: indexPath.row] {
        case let .title(text):
            if let cell = collectionView.dequeueCell(withType: TitleCollectionViewCell.self, for: indexPath) {
                cell.model = .init(title: text)
                return cell
            }

        case let .tag(tag):
            if let cell = collectionView.dequeueCell(withType: TagsCollectionViewCell.self, for: indexPath) {
                cell.model = .init(tagText: tag)
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
        return tagsCollectionViewDataSource.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellData = tagsCollectionViewDataSource[safe: indexPath.row] else { return .zero }
        switch cellData {
        case let .title(text):
            return TitleCollectionViewCell.estimateSize(title: text)
        case let .tag(tag):
            return TagsCollectionViewCell.estimateSize(tag: tag)
        }
    }
}

// MARK: - Model

extension InfoImagesCollectionViewCell {
    struct Model: Equatable {
        let imagesCount: Int
        let tags: [String]
    }
    private enum CellData: Equatable {
        case title(String)
        case tag(String)
    }
}

// MARK: - Constants

extension InfoImagesCollectionViewCell {
    private enum Constants {
        static let labelOffsetTop: CGFloat = 8.0
        static let tagsOffsetTop: CGFloat = 8.0
        static let tagsSpacing: CGFloat = 8.0
        static let relatedTitleText = "Related"
        enum ImagesCountLabel {
            static let textFormat: String = "%@ Free Images"
            static func attributedText(imagesCount: Int) -> NSAttributedString {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.groupingSeparator = " "
                let imagesCountString = formatter.string(for: imagesCount) ?? ""

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 0.9

                return NSAttributedString(
                    string: String(format: textFormat, imagesCountString),
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 18.0, weight: .semibold),
                    ]
                )
            }
        }
    }
}
