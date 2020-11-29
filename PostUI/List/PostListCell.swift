//
//  PostListCell.swift
//  PostUI
//
//  Created by Fernando Henrique Bonfim Moreno Del Rio on 11/28/20.
//

import Core
import UIKit

class PostListCell: UITableViewCell {
    @IBOutlet private weak var indicatorSize: NSLayoutConstraint?
    @IBOutlet weak var indicatorView: UIView?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var thumbnailImageView: AsyncImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var dismissButton: UIButton?
    @IBOutlet weak var commentsLabel: UILabel?
    var onDismiss: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    private func setupView() {
        indicatorView?.layer.cornerRadius = (indicatorSize?.constant ?? 0) / 2
        dismissButton?.setTitle(NSLocalizedString("Dismiss Post", comment: ""), for: .normal)
        backgroundColor = .mainBackgroundColor
        indicatorView?.backgroundColor = .indicatorColor
        authorLabel?.textColor = .mainTextColor
        timeLabel?.textColor = .mainTextColor
        titleLabel?.textColor = .mainTextColor
        dismissButton?.setTitleColor(.mainTextColor, for: .normal)
        dismissButton?.tintColor = .mainColor
        commentsLabel?.textColor = .mainColor
    }

    @IBAction func didTapDismiss() {
        onDismiss?()
    }
}
