//
//  SearchNetworkManager.swift
//  ImageSearch
//
//

import Foundation
import RxCocoa
import RxSwift

class SearchNetworkManager: NSObject {
    // MARK: - Methods

    func fetchImages(
        searchTerm: String? = nil,
        imageType: ImageTypeDomainModel = .all,
        page: Int = Constants.defaultPage,
        imagesPerPage: Int = Constants.defaultImagesPerPage
    ) -> Observable<ImageSearchResponseModel> {
        return Observable.create { [weak self] obs in
            guard let url = self?.createImageSearchURL(
                searchTerm: searchTerm,
                imageType: imageType,
                page: page,
                imagesPerPage: imagesPerPage
            ) else {
                obs.onError(NetworkManagerError.urlError)
                return Disposables.create()
            }
            let request = URLRequest(url: url)
            return URLSession.shared.rx.response(request: request).subscribe(
                onNext: { response in
                    let decoder = JSONDecoder()
                    do {
                        let model = try decoder.decode(ImageSearchResponseModel.self, from: response.data)
                        obs.onNext(model)
                    } catch {
                        obs.onError(NetworkManagerError.decodingError)
                    }
                },
                onError: { error in
                    obs.onError(error)
                }
            )
        }
    }

    private func createImageSearchURL(searchTerm: String?, imageType: ImageTypeDomainModel, page: Int, imagesPerPage: Int) -> URL? {
        var urlComps = URLComponents(string: Constants.apiURL)
        urlComps?.queryItems = queryParameters(
            searchTerm: searchTerm,
            imageType: imageType,
            page: page,
            imagesPerPage: imagesPerPage
        )
        return urlComps?.url
    }

    private func queryParameters(searchTerm: String?, imageType: ImageTypeDomainModel, page: Int, imagesPerPage: Int) -> [URLQueryItem] {
        var parameters = [
            URLQueryItem(
                name: Constants.QueryParameters.apiKey,
                value: Constants.apiKey
            ),
            URLQueryItem(
                name: Constants.QueryParameters.imageType,
                value: imageType.apiValue
            ),
            URLQueryItem(
                name: Constants.QueryParameters.pageNumber,
                value: String(page)
            ),
            URLQueryItem(
                name: Constants.QueryParameters.imagesPerPage,
                value: String(imagesPerPage)
            ),
        ]
        if let term = searchTerm {
            parameters.append(
                URLQueryItem(
                    name: Constants.QueryParameters.searchTerm,
                    value: term
                )
            )
        }
        return parameters
    }
}

// MARK: - Models

extension SearchNetworkManager {
    enum NetworkManagerError: Error {
        case urlError
        case decodingError
        case responseDataError
    }
}

// MARK: - Constants

extension SearchNetworkManager {
    private enum Constants {
        static let apiURL = "https://pixabay.com/api/"
        static let apiKey = "26682695-58a8d45feac4b7f174d86d5e4"
        static let defaultPage = 1
        static let defaultImagesPerPage = 20
        enum QueryParameters {
            static let apiKey = "key"
            static let searchTerm = "q"
            static let imageType = "image_type"
            static let pageNumber = "page"
            static let imagesPerPage = "per_page"
        }
    }
}
