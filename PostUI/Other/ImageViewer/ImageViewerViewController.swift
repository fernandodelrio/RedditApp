//
//  ImageViewerViewController.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import UIKit

class ImageViewerViewController: UIViewController {
    @IBOutlet weak var asyncImageView: AsyncImageView?
    var viewModel = ImageViewerViewModel()
    var disposeBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.load()
    }

    private func setupView() {
        asyncImageView?.imageView.contentMode = .scaleAspectFit
    }

    private func setupBindings() {
        viewModel
            .urlPublisher
            .sink { [weak self] imageURL in
                self?.asyncImageView?.loadImage(URL(string: imageURL))
            }
            .store(in: &disposeBag)
    }
}
