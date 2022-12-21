//
//  SearchViewModel.swift
//  ImageSearch
//
//

import Foundation
import RxCocoa
import RxSwift

protocol SearchViewModelDelegate: AnyObject {
    var searchModel: BehaviorRelay<MainViewModel.Model>? { get }
}

class SearchViewModel {
    // MARK: - Properties

    private let imageManager = ImageManager()

    weak var delegate: SearchViewModelDelegate? {
        didSet {
            subscribeDelegate()
        }
    }

    let showImageScreen = PublishRelay<ImageDomainModel>.init()
    let showShareImageScreen = PublishRelay<UIImage>.init()
    let showErrorDialog = PublishRelay<String>.init()
    let dismiss = PublishRelay<Void>.init()

    let imagesDomainModel = BehaviorRelay<ImageSearchDomainModel?>(value: nil)
    private let imagesResponseModel = BehaviorRelay<ImageSearchResponseModel?>(value: nil)
    private let searchNetworkManager = SearchNetworkManager()
    private var disposeBag = DisposeBag()

    // MARK: - Initialization

    init() {
        subscribe()
    }

    // MARK: - Actions

    func onSearchSubmitted(searchTerm: String?) {
        updateSearchTerm(searchTerm: searchTerm)
    }

    func onImagesRefresh() {
        refreshImages()
    }

    func onImagesLoadMore() {
        loadMoreImages()
    }

    func onTagTapped(tag: String) {
        updateSearchTerm(searchTerm: tag)
    }

    func onImageTapped(image: ImageDomainModel) {
        showImage(image: image)
    }

    func onShareButtonTapped(image: ImageDomainModel) {
        shareImage(image: image)
    }

    func onBackButtonTapped() {
        dismissViewController()
    }

    // MARK: - Methods

    private func updateSearchTerm(searchTerm: String?) {
        searchModel?.accept(.init(
            searchTerm: searchTerm,
            imageType: searchModel?.value.imageType ?? .all
        ))
    }

    private func showImage(image: ImageDomainModel) {
        showImageScreen.accept(image)
    }

    private func refreshImages() {
        loadImages(fromPage: 1)
    }

    private func loadMoreImages() {
        var page = 1
        if let hits = imagesResponseModel.value?.hits {
            page = hits.count / Constants.imagesPerPage + 1
        }
        loadImages(fromPage: page)
    }

    private func loadImages(fromPage page: Int) {
        guard let searchData = searchModel?.value else { return }
        searchNetworkManager
            .fetchImages(
                searchTerm: searchData.searchTerm,
                imageType: searchData.imageType,
                page: page,
                imagesPerPage: Constants.imagesPerPage
            )
            .subscribe(
                onNext: { [weak self] result in
                    guard let self = self else { return }
                    if page > 1, let oldImages = self.imagesResponseModel.value {
                        let mergedHits = oldImages.hits + result.hits
                        if result.totalHits > oldImages.hits.count {
                            self.imagesResponseModel.accept(
                                .init(
                                    total: result.total,
                                    totalHits: result.totalHits,
                                    hits: mergedHits
                                )
                            )
                        } else {
                            self.imagesResponseModel.accept(
                                .init(
                                    total: result.total,
                                    totalHits: result.totalHits,
                                    hits: oldImages.hits
                                )
                            )
                        }
                    } else {
                        self.imagesResponseModel.accept(result)
                    }
                },
                onError: { [weak self] error in
                    self?.imagesResponseModel.accept(nil)
                    self?.showErrorDialog.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
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

    private func dismissViewController() {
        dismiss.accept(())
    }
}

// MARK: - RX -

extension SearchViewModel {
    private func subscribe() {
        subscribeImageResponseModel()
    }

    private func subscribeImageResponseModel() {
        imagesResponseModel
            .subscribe(onNext: { [weak self] model in
                guard let data = model else {
                    self?.imagesDomainModel.accept(nil)
                    return
                }
                let tags = data.hits.reduce([String](), { partialResult, image in
                    partialResult
                        + image.tags.components(separatedBy: ", ").filter({
                            !partialResult.contains($0) && $0 != self?.searchModel?.value.searchTerm
                        })
                })
                self?.imagesDomainModel.accept(
                    .init(
                        totalImagesCount: data.total,
                        availableImagesCount: data.totalHits,
                        images: data.hits.map({
                            ImageDomainModel(
                                id: $0.id,
                                url: URL(string: $0.webformatURL),
                                width: CGFloat($0.webformatWidth),
                                height: CGFloat($0.webformatHeight)
                            )
                        }),
                        tags: tags
                    ))
            })
            .disposed(by: disposeBag)
    }

    func subscribeDelegate() {
        searchModel?
            .subscribe(onNext: { [weak self] _ in
                self?.refreshImages()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ImageDetailViewModelDelegate

extension SearchViewModel: ImageDetailViewModelDelegate {
    var allImages: ImageSearchDomainModel? {
        return imagesDomainModel.value
    }
    var searchModel: BehaviorRelay<MainViewModel.Model>? {
        return delegate?.searchModel
    }
}

// MARK: - Constants

extension SearchViewModel {
    private enum Constants {
        static let imagesPerPage: Int = 20
        enum Errors {
            static let imageLoadingError = "An error occurred while loading images"
        }
    }
}
