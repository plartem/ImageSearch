//
//  ImageTypeDomainModel.swift
//  ImageSearch
//
//

import Foundation
import SwiftyMenu

enum ImageTypeDomainModel {
    case all
    case photo
    case illustration
    case vector

    var apiValue: String {
        switch self {
        case .all: return "all"
        case .photo: return "photo"
        case .illustration: return "illustration"
        case .vector: return "vector"
        }
    }
    var description: String {
        switch self {
        case .all: return "All"
        case .photo: return "Photo"
        case .illustration: return "Illustration"
        case .vector: return "Vector"
        }
    }
}

extension ImageTypeDomainModel: SwiftyMenuDisplayable {
    var displayableValue: String {
        return description
    }

    var retrievableValue: Any {
        return self
    }
}
