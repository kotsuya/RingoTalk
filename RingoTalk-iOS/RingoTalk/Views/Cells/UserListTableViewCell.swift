//
//  UserListTableViewCell.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/16.
//

import UIKit
import SDWebImage

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
            guard let imageUrl = URL(string: user.avatarLink) else { return }
            avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            avatarImageView.sd_setImage(with: imageUrl)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
