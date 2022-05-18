//
//  FTypingListener.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import Firebase

class FTypingListener {
    
    static let shared = FTypingListener()
    
    var typingLisener: ListenerRegistration!    
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingLisener = FirestoreReference(.Typing).document(chatRoomId).addSnapshotListener({ documentSnapshot, error in
            if let error = error {
                print("failed to create typing observer: \(error)")
                return
            }
            guard let snapshot = documentSnapshot else { return }
            if snapshot.exists {
                guard let snapshotData = snapshot.data() else { return }
                for data in snapshotData {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirestoreReference(.Typing).document(chatRoomId).setData([User.currentId: false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        FirestoreReference(.Typing).document(chatRoomId).updateData([User.currentId: typing])
    }
    
    func removeTypingListener() {
        typingLisener.remove()
    }
}
