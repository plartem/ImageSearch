//
//  ImageSearchDomainModel.swift
//  ImageSearch
//
//

import Foundation
import UIKit

// MARK: - ImageSearchDomainModel

struct ImageSearchDomainModel: Equatable {
    let totalImagesCount: Int
    let availableImagesCount: Int
    let images: [ImageDomainModel]
    let tags: [String]
}
