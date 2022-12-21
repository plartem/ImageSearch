//
//  MainViewModel.swift
//  ImageSearch
//
//

import Foundation
import RxRelay
import RxSwift

class MainViewModel {
    // MARK: - Properties

    let model: BehaviorRelay<Model>
    let showSearchScreen = PublishRelay<Void>.init()
    let showLocalImagesScreen = PublishRelay<Void>.init()

    // MARK: - Initialization

    init() {
        model = .init(
            value: .init(
                searchTerm: nil,
                imageType: .all
            )
        )
    }

    // MARK: - Actions

    func onSearchSubmitted(searchTerm: String?, imageType: ImageTypeDomainModel) {
        updateSearchTerm(searchTerm: searchTerm, imageType: imageType)
    }

    func onSearchButtonTapped(searchTerm: String?, imageType: ImageTypeDomainModel) {
        updateSearchTerm(searchTerm: searchTerm, imageType: imageType)
    }

    func onLocalImagesButtonTapped() {
        showLocalImages()
    }

    // MARK: - Methods

    private func updateSearchTerm(searchTerm: String?, imageType: ImageTypeDomainModel) {
        model.accept(.init(
            searchTerm: searchTerm,
            imageType: imageType
        ))
        showSearchScreen.accept(())
    }

    private func showLocalImages() {
        showLocalImagesScreen.accept(())
    }
}

// MARK: - ImageDetailViewModelDelegate

extension MainViewModel: SearchViewModelDelegate {
    var searchModel: BehaviorRelay<Model>? {
        return model
    }
}

// MARK: - Model

extension MainViewModel {
    struct Model: Equatable {
        let searchTerm: String?
        let imageType: ImageTypeDomainModel
    }
}
