//
//  UIViewController+extension.swift
//  ImageSearch
//
//

import Foundation
import Hero
import UIKit

// MARK: - Present/Dismiss ViewController

extension UIViewController {
    enum PresentError: Error {
        case alreadyPresentingOther
    }

    func pushOrPresent(_ viewController: UIViewController) {
        if let navController = navigationController {
            navController.heroNavigationAnimationType = .slide(direction: .left)
            navController.pushViewController(viewController, animated: true)
        } else if presentedViewController == nil {
            present(viewController, animated: true, completion: nil)
        } else {
            presentError(errorMessage: GlobalConstants.Errors.viewPresentingError)
        }
    }

    func popOrDismiss() {
        if let navController = navigationController {
            navController.heroNavigationAnimationType = .slide(direction: .right)
            navController.popViewController(animated: true)
        } else if presentedViewController == self {
            dismiss(animated: true)
        } else {
            presentError(errorMessage: GlobalConstants.Errors.viewPresentingError)
        }
    }
}

// MARK: - hideKeyboardOnTappedAround

extension UIViewController {
    func hideKeyboardOnTappedAround() {
        let endEditingTapRecognizer = UITapGestureRecognizer(
            target: view,
            action: #selector(UIView.endEditing)
        )
        endEditingTapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(endEditingTapRecognizer)
    }
}

// MARK: - dismissOnLeftSwipe

extension UIViewController {
    func dismissOnLeftSwipe() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didSwipe))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func didSwipe(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: nil)
        let progress = translation.x / 2 / view.bounds.width
        switch gestureRecognizer.state {
        case .began:
            if gestureRecognizer.velocity(in: view).x > 0 {
                popOrDismiss()
            }
        case .changed:
            if Hero.shared.isTransitioning {
                Hero.shared.update(progress)
            }
        default:
            if Hero.shared.isTransitioning {
                if progress + gestureRecognizer.velocity(in: nil).x / view.bounds.width > 0.3 {
                    Hero.shared.finish()
                } else {
                    Hero.shared.cancel()
                }
            }
        }
    }
}

// MARK: - presentError

extension UIViewController {
    func presentError(errorMessage: String) {
        let alert = UIAlertController(
            title: GlobalConstants.Errors.title,
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: GlobalConstants.Errors.buttonText, style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension UIViewController {
    private enum Constants {}
}
