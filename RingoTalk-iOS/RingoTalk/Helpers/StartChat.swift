//
//  StartChat.swift
//  Message
//
//  Created by Yoo on 2022/05/13.
//

import Foundation
import Firebase

func restartChat(chatRoomId: String, memberIds: [String]) {
    // Download users using memberIds
    FUserListener.shared.getUsers(withIds: memberIds) { allUSers in
        if allUSers.count > 0 {
            createChatRoom(chatRoomId: chatRoomId, users: allUSers)
        }
    }    
}

func startChat(sender: User, receiver: User) -> String {
    var chatRoomId = ""
    
    let value = sender.id.compare(receiver.id).rawValue
    chatRoomId = value < 0 ? (sender.id + receiver.id) : (receiver.id + sender.id)
    
    createChatRoom(chatRoomId: chatRoomId, users: [sender, receiver])
    
    return chatRoomId
}

func createChatRoom(chatRoomId: String, users: [User]) {
    // if user has aleady chatroom we will not create
    
    var usersToCreateChatsFor: [String]
    usersToCreateChatsFor = []
    
    for user in users {
        usersToCreateChatsFor.append(user.id)
    }
    
    FirestoreReference(.Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId)
        .getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                // TODO : refectoring
                for chatData in snapshot.documents {
                    let currentChat = chatData.data() as Dictionary
                    if let currentUserId = currentChat[kSENDERID] {
                        if usersToCreateChatsFor.contains(currentUserId as! String) {
                            usersToCreateChatsFor.remove(at: usersToCreateChatsFor.firstIndex(of: currentUserId
                                                                                              as! String)!)
                        }
                    }
                }
            }
            
            for userId in usersToCreateChatsFor {
                let senderUser = userId == User.currentId ? User.currentUser! : getRecieverFrom(users: users)
                
                let receiverUser = userId == User.currentId ? getRecieverFrom(users: users):User.currentUser!
                
                let chatRoomObject = ChatRoom(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 1, avatarLink: receiverUser.avatarLink)
                                
                FChatRoomListener.shared.saveChatRoom(chatRoomObject)
                
            }
        
    }
}

func getRecieverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
