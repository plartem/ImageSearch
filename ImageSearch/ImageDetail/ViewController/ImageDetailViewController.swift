//
//  ImageDetailViewController.swift
//  ImageSearch
//
//

import CropViewController
import Foundation
import Hero
import Kingfisher
import RxSwift
import SnapKit
import UIKit

class ImageDetailViewController: UIViewController {
    // MARK: - Properties

    private var selectedImageHeightConstraint: Constraint?

    private let relatedImagesCollectionViewManager = RelatedImagesCollectionViewManager()
    private let viewModel: ImageDetailViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI

    private let navBarView = SearchNavigationView()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = GlobalConstants.contentBackgroundColor
        return view
    }()
    private let selectedImageView = ScalableImageView()
    private let imageDescriptionView = ImageDescriptionView()
    private let relatedLabel: UILabel = {
        let label = UILabel()
        label.attributedText = Constants.RelatedLabel.attributedText
        return label
    }()
    private let relatedImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = GlobalConstants.viewSpacing
        layout.minimumLineSpacing = GlobalConstants.viewSpacing
        layout.sectionInset = .init(
            top: GlobalConstants.viewSpacing,
            left: GlobalConstants.viewSpacing,
            bottom: GlobalConstants.viewSpacing,
            right: GlobalConstants.viewSpacing
        )

        let collectionView = SelfSizingCollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    // MARK: - Initialization

    init(viewModel: ImageDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        return nil
    }

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

        // navBarStackView
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).offset(GlobalConstants.viewSpacing)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-GlobalConstants.viewSpacing)
        }
        // scrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(GlobalConstants.viewSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }
        // contentView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }
        // selectedImageView
        contentView.addSubview(selectedImageView)
        selectedImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.leading.trailing.equalToSuperview()
        }
        // selectedImageDetailsView
        contentView.addSubview(imageDescriptionView)
        imageDescriptionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(selectedImageView.snp.bottom)
        }
        // titleLabel
        contentView.addSubview(relatedLabel)
        relatedLabel.snp.makeConstraints { make in
            make.top.equalTo(imageDescriptionView.snp.bottom).offset(GlobalConstants.viewSpacing)
            make.leading.equalToSuperview().offset(GlobalConstants.viewSpacing)
            make.trailing.equalToSuperview().offset(-GlobalConstants.viewSpacing)
        }
        // relatedImagesCollectionView
        contentView.addSubview(relatedImagesCollectionView)
        relatedImagesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(relatedLabel.snp.bottom).offset(GlobalConstants.viewSpacing)
            make.bottom.lessThanOrEqualToSuperview()
        }

        return view
    }

    private func defaultConfiguration() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.backgroundColor = GlobalConstants.backgroundColor

        navBarView.delegate = self
        selectedImageView.delegate = self
        imageDescriptionView.delegate = self

        relatedImagesCollectionViewManager.collectionView = relatedImagesCollectionView
        relatedImagesCollectionViewManager.delegate = self
        configureRelatedCollectionViewRegardingOrientation()

        hideKeyboardOnTappedAround()
        dismissOnLeftSwipe()
    }

    // MARK: - Methods

    override func traitCollectionDidChange(_: UITraitCollection?) {
        configureRelatedCollectionViewRegardingOrientation()
        selectedImageView.layoutIfNeeded()
    }

    private func configureRelatedCollectionViewRegardingOrientation() {
        guard let orientation = UIApplication.shared.orientationOfKeyWindow else { return }
        relatedImagesCollectionViewManager.changedOrientation(to: orientation)
    }
}

// MARK: - RX -

extension ImageDetailViewController {
    private func subscribe() {
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        // model
        viewModel.model
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.scrollView.setContentOffset(.zero, animated: true)

                self.relatedImagesCollectionViewManager.model = model.relatedImages

                self.selectedImageView.hero.id = "image" + String(model.selectedImage.id)
                self.selectedImageView.model = .init(imageURL: model.selectedImage.url)
                self.selectedImageHeightConstraint?.deactivate()
                self.selectedImageView.snp.makeConstraints { make in
                    self.selectedImageHeightConstraint = make.height.equalTo(self.selectedImageView.snp.width)
                        .multipliedBy(model.selectedImage.height / model.selectedImage.width)
                        .constraint
                }
            })
            .disposed(by: disposeBag)
        // searchModel
        viewModel.searchModel?
            .subscribe(onNext: { [weak self] model in
                DispatchQueue.main.async {
                    self?.navBarView.setSearchText(text: model.searchTerm)
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
        // showImageDownloadedScreen
        viewModel.showImageDownloadedScreen
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: Constants.DownloadAlert.title,
                        message: nil,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(
                        title: Constants.DownloadAlert.buttonText,
                        style: .cancel,
                        handler: nil
                    ))
                    self?.present(alert, animated: true)
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
        // showErrorDialog
        viewModel.showErrorDialog
            .subscribe(onNext: { [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.presentError(errorMessage: errorMessage)
                }
            })
            .disposed(by: disposeBag)
        // dismiss
        viewModel.dismiss
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.popOrDismiss()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ScalableImageViewDelegate

extension ImageDetailViewController: ScalableImageViewDelegate {
    func didTapCropButton() {
        viewModel.onCropButtonTapped()
    }
}

// MARK: - SearchNavigationViewDelegate

extension ImageDetailViewController: SearchNavigationViewDelegate {
    func searchNavigationView(
        _: SearchNavigationView,
        didSubmitSearchTextField textField: UITextField
    ) {
        viewModel.onSearchSubmitted(searchTerm: textField.text)
    }

    func searchNavigationView(
        _: SearchNavigationView,
        didTapRightButton _: UIButton
    ) {
        viewModel.onBackButtonTapped()
    }
}

// MARK: - ImageDescriptionViewDelegate

extension ImageDetailViewController: ImageDescriptionViewDelegate {
    func imageDescriptionView(_: ImageDescriptionView, didTapShareButton _: UIButton) {
        viewModel.onShareButtonTapped()
    }

    func imageDescriptionView(_: ImageDescriptionView, didTapDownloadButton _: UIButton) {
        viewModel.onDownloadButtonTapped()
    }
}

// MARK: - RelatedImagesCollectionViewManagerDelegate

extension ImageDetailViewController: RelatedImagesCollectionViewManagerDelegate {
    func relatedImagesCollectionViewManager(
        _: RelatedImagesCollectionViewManager,
        didSelectImage image: ImageDomainModel
    ) {
        viewModel.onRelatedImageTapped(image: image)
    }
}

// MARK: - CropViewControllerDelegate

extension ImageDetailViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect _: CGRect, angle _: Int) {
        cropViewController.popOrDismiss()
        viewModel.onImageCropped(image: image)
    }
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled _: Bool) {
        cropViewController.popOrDismiss()
    }
}

// MARK: - Constants

extension ImageDetailViewController {
    private enum Constants {
        enum RelatedLabel {
            static let attributedText: NSAttributedString = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 0.9
                return NSAttributedString(
                    string: "Related",
                    attributes: [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.main(ofSize: 18.0, weight: .semibold),
                        .foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
                    ]
                )
            }()
        }
        enum DownloadAlert {
            static let title = "Image saved"
            static let buttonText = "Ok"
        }
    }
}
