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
    @IBOutlet weak var saveButton: UIButton?
    var viewModel = ImageViewerViewModel()
    var disposeBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.load()
    }

    @IBAction func didTapSaveButtton() {
        let cacheProvider = asyncImageView?.viewModel.imageCacheProvider
        if let url = URL(string: viewModel.imageURL), let image = cacheProvider?.retrieve(url) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        dismiss(animated: true, completion: nil)
    }

    private func setupView() {
        saveButton?.setTitle(NSLocalizedString("Save Photo", comment: ""), for: .normal)
        saveButton?.tintColor = .mainColor
        view.backgroundColor = .mainBackgroundColor
        asyncImageView?.imageView.contentMode = .scaleAspectFit
        asyncImageView?.clipsToBounds = true
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
