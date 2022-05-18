//
//  Incoming.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit
import CoreLocation

class Incoming {
    
    var messagesViewController: MessagesViewController
    
    init(messagesViewController: MessagesViewController) {
        self.messagesViewController = messagesViewController
    }
    
    func createMKMessage(localMessage: LocalMessage) -> MKMessage {
        
        let mkMessage = MKMessage(message: localMessage)
        if localMessage.type == kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { [weak self] image in
                mkMessage.photoItem?.image = image
                self?.messagesViewController.messagesCollectionView.reloadData()
            }
        } else if localMessage.type == kVIDEO {
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { thumbnail in
                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { [weak self] isReadyToPlay, videoFileName in
                    let videoLink = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: videoFileName))
                    let videoItem = VideoMessage(url: videoLink)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                    mkMessage.videoItem?.image = thumbnail
                    self?.messagesViewController.messagesCollectionView.reloadData()
                }
            }
        } else if localMessage.type == kLOCATION {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude,
                                                                    longitude: localMessage.longitude))
            
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        } else if localMessage.type == kAUDIO {
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            
            mkMessage.kind = MessageKind.audio(audioMessage)
            mkMessage.audioItem = audioMessage
            
            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { audioFileName in
                let audioUrl = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: audioFileName))
                mkMessage.audioItem?.url = audioUrl
            }
            self.messagesViewController.messagesCollectionView.reloadData()
        }
        
        return mkMessage
    }
}
