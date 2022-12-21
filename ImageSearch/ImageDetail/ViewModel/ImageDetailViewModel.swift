//
//  ImageDetailViewModel.swift
//  ImageSearch
//
//

import Foundation
import RxCocoa
import RxSwift

protocol ImageDetailViewModelDelegate: AnyObject {
    var allImages: ImageSearchDomainModel? { get }
    var searchModel: BehaviorRelay<MainViewModel.Model>? { get }
}

class ImageDetailViewModel {
    // MARK: - Properties

    private let imageManager = ImageManager()

    weak var delegate: ImageDetailViewModelDelegate? {
        didSet {
            updateModel(selectedImage: model.value.selectedImage)
        }
    }
    var searchModel: BehaviorRelay<MainViewModel.Model>? {
        return delegate?.searchModel
    }

    let model: BehaviorRelay<Model>
    let showCropImageScreen = PublishRelay<UIImage>.init()
    let showShareImageScreen = PublishRelay<UIImage>.init()
    let showImageSavedDialog = PublishRelay<Void>.init()
    let showImageDownloadedScreen = PublishRelay<Void>.init()
    let showErrorDialog = PublishRelay<String>.init()
    let dismiss = PublishRelay<Void>.init()

    // MARK: - Initialization

    init(selectedImage: ImageDomainModel) {
        model = .init(value: .init(
            selectedImage: selectedImage,
            relatedImages: []
        ))
    }

    // MARK: - Actions

    func onSearchSubmitted(searchTerm: String?) {
        updateSearchTerm(searchTerm: searchTerm)
        dismissViewController()
    }

    func onRelatedImageTapped(image: ImageDomainModel) {
        updateModel(selectedImage: image)
    }

    func onShareButtonTapped() {
        shareImage(image: model.value.selectedImage)
    }

    func onDownloadButtonTapped() {
        downloadImage(image: model.value.selectedImage)
    }

    func onBackButtonTapped() {
        dismissViewController()
    }

    func onCropButtonTapped() {
        cropSelectedImage()
    }

    func onImageCropped(image: UIImage) {
        saveCroppedImage(image: image)
    }

    // MARK: - Methods

    private func relatedImagesFor(image: ImageDomainModel) -> [ImageDomainModel] {
        guard let images = delegate?.allImages?.images,
              let index = images.firstIndex(of: image) else {
            return []
        }
        var arr: [ImageDomainModel] = []
        for i in 0 ..< Constants.relatedImagesCount {
            if let item = images[safe: index + i + 1] {
                arr.append(item)
            } else if let item = images[safe: index - (Constants.relatedImagesCount - i)] {
                arr.append(item)
            }
        }
        return arr
    }

    private func updateSearchTerm(searchTerm: String?) {
        searchModel?.accept(.init(
            searchTerm: searchTerm,
            imageType: searchModel?.value.imageType ?? .all
        ))
    }

    private func updateModel(selectedImage: ImageDomainModel) {
        model.accept(.init(
            selectedImage: selectedImage,
            relatedImages: relatedImagesFor(image: selectedImage)
        ))
    }

    private func shareImage(image: ImageDomainModel) {
        imageManager.retreiveImage(url: image.url) { [weak self] result in
            switch result {
            case let .success(img):
                self?.showShareImageScreen.accept(img)

            case let .failure(error):
                self?.showErrorDialog.accept(error.localizedDescription)
            }
        }
    }

    private func downloadImage(image: ImageDomainModel) {
        imageManager.downloadImage(url: image.url) { [weak self] result in
            switch result {
            case .success:
                self?.showImageDownloadedScreen.accept(())

            case let .failure(error):
                self?.showErrorDialog.accept(error.localizedDescription)
            }
        }
    }

    private func cropSelectedImage() {
        imageManager.retreiveImage(url: model.value.selectedImage.url) { [weak self] result in
            switch result {
            case let .success(img):
                self?.showCropImageScreen.accept(img)

            case let .failure(error):
                self?.showErrorDialog.accept(error.localizedDescription)
            }
        }
    }

    private func saveCroppedImage(image: UIImage) {
        imageManager.saveImageToCroppedAlbum(image: image, completionHandler: { [weak self] result in
            switch result {
            case .success:
                self?.showImageSavedDialog.accept(())
            case let .failure(error):
                self?.showErrorDialog.accept(error.localizedDescription)
            }
        })
    }

    private func dismissViewController() {
        dismiss.accept(())
    }
}

// MARK: - Model

extension ImageDetailViewModel {
    struct Model {
        let selectedImage: ImageDomainModel
        let relatedImages: [ImageDomainModel]
    }
}

// MARK: - Constants

extension ImageDetailViewModel {
    private enum Constants {
        static let relatedImagesCount: Int = 6
    }
}
