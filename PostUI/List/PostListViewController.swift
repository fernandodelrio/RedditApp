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
    @IBOutlet private weak var bottomLoadingView: UIView?
    @IBOutlet private weak var dismissAllButton: UIButton?
    private lazy var viewModel = PostListViewModel()
    private var disposeBag = Set<AnyCancellable>()
    private var refreshControl = UIRefreshControl()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.load()
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = sender as? IndexPath {
            let destination = segue.destination as? PostDetailViewController
            destination?.viewModel.post = viewModel.posts[selectedIndexPath.row]
        }
    }

    private func setupView() {
        navigationItem.title = NSLocalizedString("Reddit Posts", comment: "")
        dismissAllButton?.setTitle(NSLocalizedString("Dismiss All", comment: ""), for: .normal)
        tableView?.isHidden = true
        bottomLoadingView?.isHidden = true
        dismissAllButton?.isHidden = true
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView?.addSubview(refreshControl)
    }

    @IBAction private func didTapDismissAll() {
        let indexPaths = (0..<viewModel.posts.count)
            .map { IndexPath(row: $0, section: 0) }
        viewModel.dismissAll()
        tableView?.performBatchUpdates { [weak self] in
            self?.tableView?.deleteRows(at: indexPaths, with: .left)
        } completion: { [weak self] _ in
            self?.tableView?.reloadData()
            self?.dismissAllButton?.isHidden = true
        }
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.refresh()
    }

    private func setupBindings() {
        viewModel
            .reloadPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let isDataAvailable = !(self?.viewModel.posts.isEmpty ?? true)
                self?.dismissAllButton?.isHidden = !isDataAvailable
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
                    self?.dismissAllButton?.isHidden = true
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
            let enumeratedPost = self?.viewModel.posts
                .enumerated()
                .first { $0.element.identifier == post.identifier }
            self?.viewModel.dismiss(identifier: post.identifier)
            if let indexPath = enumeratedPost.map({ IndexPath(row: $0.offset, section: 0) }) {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
        return cell ?? UITableViewCell()
    }
}

extension PostListViewController: UITableViewDelegate {
    // When table view reach the bottom, load more data
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == viewModel.posts.count {
            viewModel.load()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(index: indexPath.row)
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        if UIDevice.current.userInterfaceIdiom == .phone {
            performSegue(withIdentifier: "postListToDetailSegue", sender: indexPath)
        } else {
            displayDetailOnIpad(index: indexPath.row)
        }
    }

    private func displayDetailOnIpad(index: Int) {
        let viewController = storyboard?.instantiateViewController(identifier: "PostDetailViewController")
        if let destination = viewController as? PostDetailViewController {
            destination.viewModel.post = viewModel.posts[index]
            splitViewController?.showDetailViewController(destination, sender: self)
        }
    }
}
