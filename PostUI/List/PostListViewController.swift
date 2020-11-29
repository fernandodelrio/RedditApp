//
//  PostListViewController.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Combine
import Core
import UIKit

public class PostListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView?
    private lazy var viewModel = PostListViewModel()
    private var disposeBag = Set<AnyCancellable>()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.load()
    }

    private func setupView() {
        navigationItem.title = NSLocalizedString("Reddit Posts", comment: "")
        view.showLoading()
    }

    private func setupBindings() {
        viewModel
            .$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                if !posts.isEmpty {
                    self?.view.hideLoading()
                }
                self?.tableView?.reloadData()
            }
            .store(in: &disposeBag)
    }
}

extension PostListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.posts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostListCell") as? PostListCell
        let post = viewModel.posts[indexPath.row]
        cell?.indicatorView?.layer.opacity = post.isUnread ? 1 : 0
        cell?.authorLabel?.text = post.author
        cell?.timeLabel?.text = post.relativeEntryDateText
        cell?.titleLabel?.text = post.title
        cell?.commentsLabel?.text = String(
            format: NSLocalizedString("%d comments", comment: ""), post.numberOfComments
        )
        cell?.thumbnailImageView?.loadImage(URL(string: post.thumbnailURL ?? ""))
        cell?.onDismiss = { [weak self] in
            self?.viewModel.dismiss(index: indexPath.row)
        }
        return cell ?? UITableViewCell()
    }


}
