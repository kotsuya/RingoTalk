//
//  MessagesLayoutDelegate.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit

extension ChatRoomViewController: MessagesLayoutDelegate {
    
    // MARK: - Cell top label height
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section % 3 == 0 {
            if ((indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)) {
                return 40
            }
        }        
        return 10
    }
    
    // MARK: -  cell bottom label height
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    // MARK: - Message bottom height
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }
    
    // MARK: - Avatar initials
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}
