//
//  ImageManager.swift
//  ImageSearch
//
//

import Foundation
import Kingfisher
import Photos
import UIKit

class ImageManager {
    enum ImageSaveError: Error {
        case fetchAlbumError
        case saveImageError
    }
    typealias CompletionHandler = (Result<UIImage, Error>) -> Void

    // MARK: - Methods

    func retreiveImage(
        url optionalUrl: URL?,
        completionHandler: @escaping CompletionHandler
    ) {
        guard let url = optionalUrl else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case let .success(value):
                completionHandler(.success(value.image))

            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func downloadImage(url optionalUrl: URL?, completionHandler: @escaping CompletionHandler) {
        guard let url = optionalUrl else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case let .success(value):
                let responder = ImageWriteToSavedPhotosAlbumResponder(completionHandler: completionHandler)
                UIImageWriteToSavedPhotosAlbum(
                    value.image,
                    responder,
                    #selector(ImageWriteToSavedPhotosAlbumResponder.image),
                    nil
                )

            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", Constants.croppedImagesDirectory)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }

    func fetchOrCreateAssetCollectionForAlbum(completionHandler: @escaping (Result<PHAssetCollection, Error>) -> Void) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            completionHandler(.success(assetCollection))
        } else {
            PHPhotoLibrary.shared()
                .performChanges(
                    {
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(
                            withTitle: Constants.croppedImagesDirectory
                        )
                    },
                    completionHandler: { [weak self] success, error in
                        if success {
                            if let assetCollection = self?.fetchAssetCollectionForAlbum() {
                                completionHandler(.success(assetCollection))
                            } else {
                                completionHandler(.failure(ImageSaveError.fetchAlbumError))
                            }
                        } else {
                            completionHandler(.failure(error ?? ImageSaveError.fetchAlbumError))
                        }
                    }
                )
        }
    }

    func saveImageToCroppedAlbum(image: UIImage, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        fetchOrCreateAssetCollectionForAlbum { result in
            switch result {
            case let .success(assetCollection):
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                    if let placeholder = assetPlaceholder {
                        let enumeration: NSArray = [placeholder]
                        albumChangeRequest?.addAssets(enumeration)
                    }
                }, completionHandler: { success, error in
                    if success {
                        completionHandler(.success(()))
                    } else {
                        completionHandler(.failure(error ?? ImageSaveError.saveImageError))
                    }
                })
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}

extension ImageManager {
    class ImageWriteToSavedPhotosAlbumResponder: NSObject {
        private var completionHandler: CompletionHandler?

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
            super.init()
        }

        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo _: UnsafeRawPointer) {
            guard let handler = completionHandler else { return }
            if let err = error {
                handler(.failure(err))
            } else {
                handler(.success(image))
            }
            completionHandler = nil
        }
    }
}

extension ImageManager {
    private enum Constants {
        static let croppedImagesDirectory = "cropped"
    }
}
