//
//  SearchViewController.swift
//  ImageSearch
//
//

import CCBottomRefreshControl
import Foundation
import Kingfisher
import RxSwift
import SnapKit
import UIKit

class SearchViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: SearchViewModel
    private let imageSearchCollectionViewManager = ImagesCollectionViewManager()
    private let disposeBag = DisposeBag()

    // MARK: - UI

    private let navBarView = SearchNavigationView()
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

    // MARK: - Initialization

    init(viewModel: SearchViewModel) {
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
        // imagesCollectionView
        view.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(GlobalConstants.viewSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return view
    }

    private func defaultConfiguration() {
        navigationController?.isNavigationBarHidden = true

        view.backgroundColor = GlobalConstants.backgroundColor

        navBarView.delegate = self

        imageSearchCollectionViewManager.collectionView = imagesCollectionView
        imageSearchCollectionViewManager.delegate = self

        hideKeyboardOnTappedAround()
        dismissOnLeftSwipe()
    }

    // MARK: - Methods

    override func traitCollectionDidChange(_: UITraitCollection?) {
        imagesCollectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - RX -

extension SearchViewController {
    private func subscribe() {
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        // imagesDomainModel
        viewModel.imagesDomainModel
            .subscribe(onNext: { [weak self] model in
                guard let self = self, let data = model else { return }
                DispatchQueue.main.async {
                    if !data.images.isEmpty {
                        self.imageSearchCollectionViewManager.dataSource =
                            [
                                .info(
                                    .init(imagesCount: data.totalImagesCount, tags: data.tags)
                                ),
                            ]
                            + data.images.map({
                                .image(
                                    .init(
                                        id: $0.id,
                                        image: .url($0.url),
                                        width: $0.width,
                                        height: $0.height
                                    )
                                )
                            })
                    } else {
                        self.imageSearchCollectionViewManager.dataSource = [ .loader ]
                    }
                }
            })
            .disposed(by: disposeBag)
        // searchModel
        viewModel.searchModel?
            .subscribe(onNext: { [weak self] model in
                DispatchQueue.main.async {
                    self?.navBarView.setSearchText(text: model.searchTerm)
                }
                self?.imageSearchCollectionViewManager.dataSource = [.loader]
            })
            .disposed(by: disposeBag)
        // showImageScreen
        viewModel.showImageScreen
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let viewModel = ImageDetailViewModel(selectedImage: image)
                    viewModel.delegate = self.viewModel
                    let viewController = ImageDetailViewController(viewModel: viewModel)
                    self.pushOrPresent(viewController)
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

// MARK: - SearchNavigationViewDelegate

extension SearchViewController: SearchNavigationViewDelegate {
    func searchNavigationView(_: SearchNavigationView, didSubmitSearchTextField textField: UITextField) {
        viewModel.onSearchSubmitted(searchTerm: textField.text)
    }

    func searchNavigationView(
        _: SearchNavigationView,
        didTapRightButton _: UIButton
    ) {
        viewModel.onBackButtonTapped()
    }
}

// MARK: - ImageSearchCollectionViewManagerDelegate

extension SearchViewController: ImagesCollectionViewManagerDelegate {
    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didSelectImage image: ImagesCollectionViewManager.ImageModel) {
        if let imageModel = viewModel.imagesDomainModel.value?.images.first(where: { $0.id == image.id }) {
            viewModel.onImageTapped(image: imageModel)
        }
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTapShareButtonForImage image: ImagesCollectionViewManager.ImageModel) {
        if let imageModel = viewModel.imagesDomainModel.value?.images.first(where: { $0.id == image.id }) {
            viewModel.onImageTapped(image: imageModel)
        }
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTapTag tag: String) {
        viewModel.onTagTapped(tag: tag)
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTriggerRefresh _: UICollectionView?) {
        viewModel.onImagesRefresh()
    }

    func imagesCollectionViewManager(_: ImagesCollectionViewManager, didTriggerLoadMore _: UICollectionView?) {
        viewModel.onImagesLoadMore()
    }
}
