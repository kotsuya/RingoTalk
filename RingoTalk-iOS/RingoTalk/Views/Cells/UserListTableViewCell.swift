//
//  UserListTableViewCell.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/16.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    static let identifier = "UserListTableViewCell"

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet { avatarImageView.circleImage() }
    }
    @IBOutlet weak var usernameLabel: UILabel!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ user: User) {
        usernameLabel.text = user.username
        
        if !user.avatarLink.isEmpty {
            FileStorage.downloadImage(imageUrl: user.avatarLink) { [weak self] avatarImage in
                self?.avatarImageView.image = avatarImage
            }
        }
    }
}
