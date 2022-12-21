//
//  ImageSearchResponseModel.swift
//  ImageSearch
//
//

import Foundation

// MARK: - ImageSearchResponseModel

struct ImageSearchResponseModel: Codable {
    let total: Int
    let totalHits: Int
    let hits: [HitModel]

    enum CodingKeys: String, CodingKey {
        case total
        case totalHits
        case hits
    }
}

// MARK: - HitModel

extension ImageSearchResponseModel {
    struct HitModel: Codable {
        let id: Int
        let pageURL: String
        let type: String
        let tags: String
        let previewURL: String
        let previewWidth: Int
        let previewHeight: Int
        let webformatURL: String
        let webformatWidth: Int
        let webformatHeight: Int
        let largeImageURL: String
        let fullHDURL: String?
        let imageURL: String?
        let imageWidth: Int
        let imageHeight: Int
        let imageSize: Int
        let views: Int
        let downloads: Int
        let likes: Int
        let comments: Int
        let userID: Int
        let user: String
        let userImageURL: String

        enum CodingKeys: String, CodingKey {
            case id
            case pageURL
            case type
            case tags
            case previewURL
            case previewWidth
            case previewHeight
            case webformatURL
            case webformatWidth
            case webformatHeight
            case largeImageURL
            case fullHDURL
            case imageURL
            case imageWidth
            case imageHeight
            case imageSize
            case views
            case downloads
            case likes
            case comments
            case userID = "user_id"
            case user
            case userImageURL
        }
    }
}
