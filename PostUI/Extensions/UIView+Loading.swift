//
//  UIView+Loading.swift
//  Core
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import UIKit

public extension UIView {
    // Shows a loading in the middle of the view
    func showLoading() {
        hideLoading()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        let centerYConstraint = activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)

        addSubview(activityIndicator)
        addConstraints([centerXConstraint, centerYConstraint])
        layoutIfNeeded()
    }

    // Hides the loading
    func hideLoading() {
        subviews
            .compactMap { $0 as? UIActivityIndicatorView }
            .forEach { $0.removeFromSuperview() }
        layoutIfNeeded()
    }
}
