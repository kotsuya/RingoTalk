//
//  FMessageListener.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FMessageListener {
    
    static let shared = FMessageListener()
    
    var newMessageListener: ListenerRegistration!
    var updateMessageListener: ListenerRegistration!
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            try FirestoreReference(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
            
        } catch {
            print("error saving message to firestore",  error.localizedDescription)
        }
    }
     
    // MARK: - send channel
    
    func addChannelMessage(_ message: LocalMessage, channel: Channel) {
        do {
            try FirestoreReference(.Message).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
            
        } catch {
            print("error saving message to firestore",  error.localizedDescription)
        }
    }
    
    // MARK: - Chark for old message
    
    func checkForOldMessage(_ documentId: String, collectionId: String) {
        FirestoreReference(.Message).document(documentId).collection(collectionId).getDocuments { snapshot, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let doucments = snapshot?.documents else { return }
            var oldMessages = doucments.compactMap { query -> LocalMessage? in
                return try? query.data(as: LocalMessage.self)
            }
            oldMessages.sort(by: { $0.date < $1.date })
            
            for message in oldMessages {
                RealmManager.shared.save(message)
            }
        }
    }
    
    func listenForNewMessages(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newMessageListener = FirestoreReference(.Message).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            if message.senderId != User.currentId {
                                RealmManager.shared.save(message)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    // MARK: - Updadte message status
    
    func updateMessageStatus(_ message: LocalMessage, userId: String) {
        let values = [kSTATUS: kREAD, kREADDATE: Date()] as [String: Any]
        FirestoreReference(.Message).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
    }
    
    // MARK: - Listen for Read status updates
    
    func listenForReadStats(_ documentId: String, collecitonId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updateMessageListener = FirestoreReference(.Message).document(documentId).collection(collecitonId).addSnapshotListener({ querySnapshot, error in
            guard let snapShot = querySnapshot else { return }
            
            for change in snapShot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        }
                    case .failure(let error):
                        print("Error decoding", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    
    func removeMessageListener() {
        newMessageListener.remove()
        if updateMessageListener != nil {
            updateMessageListener.remove()
        }
    }
}
