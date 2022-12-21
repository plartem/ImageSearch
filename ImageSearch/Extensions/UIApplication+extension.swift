//
//  UIApplication+extension.swift
//  ImageSearch
//
//

import Foundation
import UIKit

extension UIApplication {
    var orientationOfKeyWindow: UIInterfaceOrientation? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .windowScene?
            .interfaceOrientation
    }
}
