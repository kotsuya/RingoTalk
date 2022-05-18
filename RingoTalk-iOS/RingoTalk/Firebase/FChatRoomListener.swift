//
//  FChatRoomListener.swift
//  Message
//
//  Created by Yoo on 2022/05/13.
//

import Foundation
import Firebase

class FChatRoomListener {
    
    static let shared = FChatRoomListener()
    
    func saveChatRoom(_ chatRoom: ChatRoom) {        
        do {
            try FirestoreReference(.Chat).document(chatRoom.id).setData(from: chatRoom)
        } catch {
            print("No able to save documents", error.localizedDescription)
        }
    }
    
    // MARK: - Delete function
    
    func deleteChatRoom(_ chatRoom: ChatRoom) {
        FirestoreReference(.Chat).document(chatRoom.id).delete()
    }
        
    // MARK: - Download all chat rooms
    
    func downloadChatRooms(completion: @escaping (_ allFBChatRooms: [ChatRoom]) -> Void) {
        FirestoreReference(.Chat).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { snapshot, error in
            var chatRooms: [ChatRoom] = []
            guard let documents = snapshot?.documents else {
                print("no documents found")
                return
            }
            
            let allFBChatRooms = documents.compactMap { snapshot -> ChatRoom? in
                return try? snapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allFBChatRooms {
                if chatRoom.lastMessage != "" {
                    chatRooms.append(chatRoom)
                }
            }
            
            chatRooms.sort(by: { $0.date! > $1.date! })
            completion(chatRooms)
        }
    }
    
    func getChatRoom(chatRoomId: String, completion: @escaping (_ chatRoom: ChatRoom?) -> Void) {
        FirestoreReference(.Chat).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("no documents found")
                return
            }
            
            let allFBChatRooms = documents.compactMap { snapshot -> ChatRoom? in
                return try? snapshot.data(as: ChatRoom.self)
            }
            
            let chatRooms = allFBChatRooms.filter({ $0.chatRoomId == chatRoomId })
            completion(chatRooms.first)
        }
    }
    
    
    // MARK: - reset unread counter
    
    func clearUnreadCounter(chatRoom: ChatRoom) {
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        saveChatRoom(newChatRoom)
    }
    
    func clearUnreadCounterUsingChatRoomId(chatRoomId: String) {
        FirestoreReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { [weak self] querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else { return }
            
            let allChatRooms = documents.compactMap { snapShot -> ChatRoom? in
                return try? snapShot.data(as: ChatRoom.self)
            }
            
            if allChatRooms.count > 0,
               let chatRoom = allChatRooms.first {
                self?.clearUnreadCounter(chatRoom: chatRoom)
            }
            
        }
    }
    
    
    // MARK: - Update Chatroom with New message
    
    private func updateChatRoomWithNewMessage(chatRoom: ChatRoom, lastMessage: String) {
        var tempChatRoom = chatRoom
        
        if tempChatRoom.senderId != User.currentId {
            tempChatRoom.unreadCounter += 1
        }
        
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        saveChatRoom(tempChatRoom)
    }
    
    func updateChatRooms(chatRoomId: String, lastMessage: String) {
        FirestoreReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { [weak self] snapShot, error in
            guard let documents = snapShot?.documents else { return }
            let allChatRooms = documents.compactMap { querySnapshot -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allChatRooms {
                self?.updateChatRoomWithNewMessage(chatRoom: chatRoom, lastMessage: lastMessage)
            }
        }
    }
}
