//
//  ChatListTableViewCell.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/16.
//

import UIKit
import SDWebImage

class ChatListTableViewCell: UITableViewCell {
    
    static let identifier = "ChatListTableViewCell"
       
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet { avatarImageView.circleImage() }
    }
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel! {
        didSet { unreadCountLabel.circleImage() }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        lastMessageLabel.text = nil
        usernameLabel.text = nil
        dateLabel.text = nil
        unreadCountLabel.text = nil
    }
    
    func configure(_ chatRoom: ChatRoom) {
        
        usernameLabel.text = chatRoom.receiverName
        lastMessageLabel.text = chatRoom.lastMessage
        
        if chatRoom.unreadCounter > 0 {
            unreadCountLabel.text = "\(chatRoom.unreadCounter)"
            unreadCountLabel.isHidden = false
        } else {
            unreadCountLabel.isHidden = true
        }
        
        if !chatRoom.avatarLink.isEmpty {
            guard let imageUrl = URL(string: chatRoom.avatarLink) else { return }
            avatarImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            avatarImageView.sd_setImage(with: imageUrl)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
        
        if let date = chatRoom.date {
            dateLabel.text = timeElapsed(date)
        }
    }
}
