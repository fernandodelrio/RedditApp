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
    @IBOutlet weak var bottomLoadingView: UIView?
    private lazy var viewModel = PostListViewModel()
    private var disposeBag = Set<AnyCancellable>()
    private var refreshControl = UIRefreshControl()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.load()
    }

    private func setupView() {
        navigationItem.title = NSLocalizedString("Reddit Posts", comment: "")
        tableView?.isHidden = true
        bottomLoadingView?.isHidden = true
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView?.addSubview(refreshControl)
    }

    @objc func refresh(_ sender: AnyObject) {
        viewModel.refresh()
    }

    private func setupBindings() {
        viewModel
            .reloadPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView?.reloadData()
            }
            .store(in: &disposeBag)
        viewModel
            .loadingStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadingState in
                self?.tableView?.isHidden = loadingState == .showMiddleLoading
                self?.bottomLoadingView?.isHidden = loadingState != .showBottomLoading
                if loadingState == .showMiddleLoading {
                    self?.view.showLoading()
                } else {
                    self?.view.hideLoading()
                }
                if loadingState == .hideLoading {
                    self?.refreshControl.endRefreshing()
                }
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
        if let thumbnailURL = post.thumbnailURL {
            cell?.thumbnailImageView?.loadImage(URL(string: thumbnailURL))
        }
        cell?.onDismiss = { [weak self] in
            self?.viewModel.dismiss(index: indexPath.row)
            tableView.performBatchUpdates {
                tableView.deleteRows(at: [indexPath], with: .left)
            } completion: { _ in
                tableView.reloadData()
            }
        }
        return cell ?? UITableViewCell()
    }
}
