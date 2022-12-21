//
//  ImageDomainModel.swift
//  ImageSearch
//
//

import Foundation
import UIKit

// MARK: - ImageDomainModel

struct ImageDomainModel: Equatable {
    let id: Int
    let url: URL?
    let width: CGFloat
    let height: CGFloat
}
