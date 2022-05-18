//
//  MKMessage.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var sender: SenderType { return self.mkSender }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    var mkSender: MKSender
    var senderInitials: String
    var status: String
    var readDate: Date
    var incoming: Bool
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?
    var audioItem: AudioMessage?
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId,
                                 displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.senderInitials = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        case kVIDEO:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude,
                                                                    longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem
        case kAUDIO:
            let audioItem = AudioMessage(duration: 2.0)
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown mkMessage type")
        }
    }
}
