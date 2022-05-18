//
//  MessagesDisplayDelegate.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit

extension ChatRoomViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard let bubbleColorOutgoing = UIColor(named: "colorOutgoingBubble"),
              let bubbleColorIncoming = UIColor(named: "colorIncomingBubble") else {
            return .secondarySystemBackground
        }
        
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing:bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ?  .bottomRight:.bottomLeft
        return .bubbleTail(tail, .curved)
    }
}
