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
    @IBOutlet private weak var titleLabel: UILabel?
    private var disposeBag = Set<AnyCancellable>()
    @ObservedObject var viewModel = PostDetailsViewModel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.load()
    }

    private func setupBindings() {
        viewModel
            .$image
            .sink { [weak self] image in
                self?.imageView?.loadImage(URL(string: image))
            }
            .store(in: &disposeBag)
        viewModel
            .$title
            .sink { [weak self] title in
                self?.titleLabel?.text = title
            }
            .store(in: &disposeBag)
    }
}
