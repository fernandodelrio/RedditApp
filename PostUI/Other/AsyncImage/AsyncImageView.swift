//
//  AsyncImageView.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import UIKit

public class AsyncImageView: UIView {
    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10.0
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private var disposeBag = Set<AnyCancellable>()

    var viewModel = AsyncImageViewModel()

    public override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()
        setupImageViewConstraints()
    }

    public func loadImage(_ url: URL?) {
        showLoading()
        viewModel
            .loadImage(url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
                self?.hideLoading()
            }
            .store(in: &disposeBag)
    }

    private func setupShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.5
        clipsToBounds = false
    }

    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
