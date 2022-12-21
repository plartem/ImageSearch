//
//  LocalImagesViewModel.swift
//  ImageSearch
//
//

import Foundation
import Photos
import RxCocoa
import RxSwift

class LocalImagesViewModel {
    // MARK: - Properties

    private let imageManager = ImageManager()
    private let phImageManager = PHImageManager.default()

    let showCropImageScreen = PublishRelay<UIImage>.init()
    let showImageSavedDialog = PublishRelay<Void>.init()
    let showShareImageScreen = PublishRelay<UIImage>.init()
    let showErrorDialog = PublishRelay<String>.init()

    let localImagesModel = BehaviorRelay<Model>(value: .init(totalCount: 0, images: []))
    private var imagesAssets = BehaviorRelay<PHFetchResult<PHAsset>?>(value: nil)

    private let disposeBag = DisposeBag()

    // MARK: - Initialization

    init() {
        subscribe()
        refreshImages()
    }

    // MARK: - Actions

    func onImagesRefresh() {
        refreshImages()
    }

    func onImagesLoadMore() {
        loadMoreImages()
    }

    func onShareButtonTapped(index: Int) {
        shareImage(index: index)
    }

    func onImageTapped(index: Int) {
        cropImage(index: index)
    }

    func onImageCropped(image: UIImage) {
        saveCroppedImage(image: image)
    }

    // MARK: - Methods

    private func refreshImages() {
        updateImagesAssets()
    }

    private func updateImagesAssets() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            switch status {
            case .authorized,
                 .limited:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = Constants.assetsSortDescriptors
                self?.imagesAssets.accept(PHAsset.fetchAssets(with: .image, options: fetchOptions))
            case .denied,
                 .restricted:
                self?.imagesAssets.accept(nil)
                self?.showErrorDialog.accept(GlobalConstants.Errors.photosNotAuthorizedError)
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    private func loadMoreImages() {
        guard let assets = imagesAssets.value else { return }

        let startIndex = localImagesModel.value.images.count
        let endIndex = min(startIndex + Constants.imagesPerPage, assets.count)
        guard startIndex < endIndex else {
            localImagesModel.accept(localImagesModel.value)
            return
        }

        var model = localImagesModel.value
        for i in startIndex ..< endIndex {
            let asset = assets[i]
            let imageWidth = min(CGFloat(asset.pixelWidth), Constants.imageMaxWidth)
            let imageHeight = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth) * imageWidth
            model.images.append(
                .init(
                    image: nil,
                    width: imageWidth,
                    height: imageHeight
                )
            )
        }
        localImagesModel.accept(model)

        for i in startIndex ..< endIndex {
            let asset = assets[i]
            if let imageModel = localImagesModel.value.images[safe: i] {
                phImageManager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: imageModel.width, height: imageModel.height),
                    contentMode: .aspectFit,
                    options: Constants.assetsRequestsOptions,
                    resultHandler: { [weak self] image, _ in
                        guard let self = self else { return }
                        var model = self.localImagesModel.value
                        model.images[i].image = image
                        self.localImagesModel.accept(model)
                    }
                )
            }
        }
    }

    private func shareImage(index: Int) {
        guard let assets = imagesAssets.value, index < assets.count else { return }

        let asset = assets[index]
        phImageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: Constants.assetsRequestsOptions,
            resultHandler: { [weak self] optionalImage, _ in
                guard let self = self, let image = optionalImage else { return }
                self.showShareImageScreen.accept(image)
            }
        )
    }

    private func cropImage(index: Int) {
        guard let assets = imagesAssets.value, index < assets.count else { return }

        let asset = assets[index]
        phImageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: Constants.assetsRequestsOptions,
            resultHandler: { [weak self] optionalImage, _ in
                guard let self = self, let image = optionalImage else { return }
                self.showCropImageScreen.accept(image)
            }
        )
    }

    private func saveCroppedImage(image: UIImage) {
        imageManager.saveImageToCroppedAlbum(image: image, completionHandler: { [weak self] result in
            switch result {
            case .success:
                self?.refreshImages()
                self?.showImageSavedDialog.accept(())
            case let .failure(error):
                self?.showErrorDialog.accept(error.localizedDescription)
            }
        })
    }
}

// MARK: - RX -

extension LocalImagesViewModel {
    private func subscribe() {
        subscribeImagesAssets()
    }

    private func subscribeImagesAssets() {
        imagesAssets
            .subscribe(onNext: { [weak self] model in
                self?.localImagesModel.accept(.init(totalCount: model?.count ?? 0, images: []))
                self?.loadMoreImages()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Model

extension LocalImagesViewModel {
    struct Model {
        let totalCount: Int
        var images: [ImageModel]
    }
    struct ImageModel {
        var image: UIImage?
        let width: CGFloat
        let height: CGFloat
    }
}

// MARK: - Constants

extension LocalImagesViewModel {
    private enum Constants {
        static let assetsSortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        static let assetsRequestsOptions: PHImageRequestOptions = {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat
            return requestOptions
        }()
        static let imagesPerPage: Int = 20
        static let imageMaxWidth: CGFloat = 512.0
    }
}
