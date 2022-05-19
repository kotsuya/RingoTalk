//
//  Outgoing.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery
import ProgressHUD

class Outgoing {
    class func sendMessage(chatRoomId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?,  memberIds: [String]) {
        // 1. Create local message from the data we have
        
        guard let currentUser = User.currentUser else {
            ProgressHUD.showError("Current User does not exist.")
            return
        }
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatRoomId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderinitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        // 2. Check message type
        if let text = text {
            if text.hasPrefix("https://") {
                sendlinkPreview(message: message, text: text, memberIds: memberIds)
            } else {
                sendText(message: message, text: text, memberIds: memberIds)
            }
        }
        
        if let photo = photo {
            sendPhoto(message: message, photo: photo, memberIds: memberIds)
        }
        
        if let video = video {
            sendVideo(message: message, video: video, memberIds: memberIds)
        }
        
        if let location = location {
            sendLocation(message: message, location: location, memberIds: memberIds)
        }
        
        if let audio = audio {
            sendAudio(message: message, audioFileName: audio, audioDuration: audioDuration, memberIds: memberIds)
        }
                
        FChatRoomListener.shared.updateChatRooms(chatRoomId: chatRoomId,
                                                 lastMessage: message.message)
        
        sendNotification(userIds: memberIds, title: message.senderName, body: message.message)
    }
     
    class func saveMessage(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.save(message)
        
        for memberId in memberIds {
            FMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}

func sendlinkPreview(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    
    message.message = text
    message.type = kLINKPREVIEW
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

func sendText(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    
    message.message = text
    message.type = kTEXT
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

func sendPhoto(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {
    guard let pngData = photo.pngData() as? NSData else { return }
    
    message.message = "Photo Message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/\(message.chatRoomId)_\(fileName).png"
    
    FileStorage.saveFileLocally(fileData: pngData, fileName: fileName)
    FileStorage.uploadImage(photo, directory: fileDirectory) { imageUrl in
        if let url = imageUrl {
            message.pictureUrl = url
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }
}

func sendVideo(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
    
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/\(message.chatRoomId)_\(fileName).png"
    let videoDirectory = "MediaMessages/Video/\(message.chatRoomId)_\(fileName).mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { processedVideo, videoUrl in
        if let videoUrl = videoUrl {
            let thumbnail = videoThumbnail(videoUrl: videoUrl)
            guard let pngData = thumbnail.pngData() as? NSData else { return }
            FileStorage.saveFileLocally(fileData: pngData, fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { imageLink in
                if let imageLink = imageLink {
                    if let videoData = NSData(contentsOf: videoUrl) {
                        FileStorage.saveFileLocally(fileData: videoData, fileName: fileName + ".mov")
                        FileStorage.uploadVideo(videoData as Data, directory: videoDirectory) { videoLink in
                            if let videoLink = videoLink {
                                message.videoUrl = videoLink
                                message.pictureUrl = imageLink
                                Outgoing.saveMessage(message: message, memberIds: memberIds)
                            }
                        }
                    }
                }
            }
        }
    }
}

func sendLocation(message: LocalMessage, location: String, memberIds: [String], channel: Channel? = nil) {
    
    let currentLocation = location.components(separatedBy: "_")
    
    message.message = "Location Message"
    message.type = kLOCATION
    message.latitude = Double(currentLocation[1]) ?? 0.0
    message.longitude = Double(currentLocation[0]) ?? 0.0
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

func sendAudio(message: LocalMessage, audioFileName: String,
               audioDuration: Float, memberIds: [String], channel: Channel? = nil) {
   
    message.message = "Audio Message"
    message.type = kAUDIO
    
    let fileDirectory = "MediaMessages/Audio/\(message.chatRoomId)_\(audioFileName).m4a"
        
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { audioLink in
        if let audioLink = audioLink {
            message.audioUrl = audioLink
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }
}

func sendNotification(userIds: [String], title: String, body: String) {    
    FUserListener.shared.getUsers(withIds: userIds) { users in
        for user in users {            
            if user.id != User.currentId {
                let sender = PushNotificationSender()
                sender.sendPushNotification(to: user.pushId, title: title, body: body)
            }
        }
    }
}
