//
//  PostDetailViewController.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/29/20.
//

import Combine
import Core
import UIKit
import SwiftUI

public class PostDetailViewController: UIViewController {
    @IBOutlet private weak var imageView: AsyncImageView?
    @IBOutlet private weak var authorLabel: UILabel?
    @IBOutlet private weak var titleLabel: UILabel?
    private var disposeBag = Set<AnyCancellable>()
    @ObservedObject var viewModel = PostDetailsViewModel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupView()
        viewModel.load()
    }

    private func setupView() {
        imageView?.isHidden = true
    }

    private func setupBindings() {
        viewModel
            .$imageURL
            .sink { [weak self] imageURL in
                self?.imageView?.isHidden = false
                self?.imageView?.loadImage(URL(string: imageURL))
            }
            .store(in: &disposeBag)
        viewModel
            .$title
            .sink { [weak self] title in
                self?.titleLabel?.text = title
            }
            .store(in: &disposeBag)
        viewModel
            .$author
            .sink { [weak self] author in
                self?.authorLabel?.text = author
            }
            .store(in: &disposeBag)
    }
}
