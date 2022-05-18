//
//  InputBarAccessoryViewDelegate.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit
import InputBarAccessoryView

extension ChatRoomViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicButtonStatus(show: text == "")
        
        if !text.isEmpty {
            startTypingIndicator()
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        
    }
}
