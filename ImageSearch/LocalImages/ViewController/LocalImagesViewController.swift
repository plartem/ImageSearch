//
//  LocalImagesViewController.swift
//  ImageSearch
//
//

import CropViewController
import Foundation
import RxSwift
import SnapKit
import UIKit

class LocalImagesViewController: UIViewController {
    // MARK: - Properties

    private let viewModel = LocalImagesViewModel()
    private let imagesCollectionViewManager = ImagesCollectionViewManager()
    private let disposeBag = DisposeBag()

    // MARK: - UI

    private let imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = GlobalConstants.viewSpacing
        layout.sectionInset = .init(
            top: 0.0,
            left: GlobalConstants.viewSpacing,
            bottom: GlobalConstants.viewSpacing,
            right: GlobalConstants.viewSpacing
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    // MARK: - Lifecycle

    override func loadView() {
        view = buildView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        defaultConfiguration()
    }

    // MARK: Configurations

    private func buildView() -> UIView {
        let view = UIView()

        // imagesCollectionView
        view.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        return view
    }

    private func defaultConfiguration() {
        navigationController?.isNavigationBarHidden = false
        title = Constants.title

        view.backgroundColor = GlobalConstants.contentBackgroundColor

        imagesCollectionViewManager.collectionView = imagesCollectionView
        imagesCollectionViewManager.delegate = self

        dismissOnLeftSwipe()
    }

    // MARK: - Methods

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
    }
}

// MARK: - RX -

extension LocalImagesViewController {
    private func subscribe() {
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        // imagesDomainModel
        viewModel.localImagesModel
            .subscribe(onNext: { model in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if !model.images.isEmpty {
                        self.imagesCollectionViewManager.dataSource =
                            [.info(.init(imagesCount: model.totalCount, tags: []))]
                                + model.images.enumerated().map({ index, element in
                                    .image(.init(
                                        id: index,
                                        image: .image(element.image),
                                        width: element.width,
                                        height: element.height
                                    ))
                                })
                    } else {
                        self.imagesCollectionViewManager.dataSource = [.loader]
                    }
                }
            })
            .disposed(by: disposeBag)
        // showCropImageScreen
        viewModel.showCropImageScreen
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let cropViewController = CropViewController(image: image)
                    cropViewController.delegate = self
                    self.pushOrPresent(cropViewController)
                }
            })
            .disposed(by: disposeBag)
        // showImageSavedDialog
        viewModel.showImageSavedDialog
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: GlobalConstants.CroppedImageSavedDialog.title,
                        message: nil,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(
                        title: GlobalConstants.CroppedImageSavedDialog.buttonText,
                        style: .cancel,
                        handler: nil
                    ))
                    self?.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
        // showShareImageScreen
        viewModel.showShareImageScreen
            .subscribe(onNext: { [weak self] image in
                DispatchQueue.main.async {
                    let activityViewController = UIActivityViewController(
                        activityItems: [image],
                        applicationActivities: nil
                    )
                    self?.present(activityViewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
        // showErrorDialog
        viewModel.showErrorDialog
            .subscribe(onNext: { [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.presentError(errorMessage: errorMessage)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ImagesCollectionViewManagerDelegate

extension LocalImagesViewController: ImagesCollectionViewManagerDelegate {
    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didSelectImage image: ImagesCollectionViewManager.ImageModel) {
        viewModel.onImageTapped(index: image.id)
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTapShareButtonForImage image: ImagesCollectionViewManager.ImageModel) {
        viewModel.onShareButtonTapped(index: image.id)
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTapTag _: String) {}

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTriggerRefresh _: UICollectionView?) {
        viewModel.onImagesRefresh()
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTriggerLoadMore _: UICollectionView?) {
        viewModel.onImagesLoadMore()
    }
}

// MARK: - CropViewControllerDelegate

extension LocalImagesViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        cropViewController.popOrDismiss()
        viewModel.onImageCropped(image: image)
    }
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled _: Bool) {
        cropViewController.popOrDismiss()
    }
}

// MARK: - Constants

extension LocalImagesViewController {
    private enum Constants {
        static let title = "Local Images"
    }
}
