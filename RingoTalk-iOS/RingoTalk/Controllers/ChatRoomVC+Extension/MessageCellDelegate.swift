//
//  MessageCellDelegate.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser
import SafariServices

extension ChatRoomViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if let photoItem = mkMessage.photoItem,
                let photoImage = photoItem.image {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(photoImage)
                images.append(photo)
                
                let browser  = SKPhotoBrowser(photos: images)
                present(browser, animated: true)
            }
            
            if let videoItem = mkMessage.videoItem,
                let videoUrl = videoItem.url {
                let playerController = AVPlayerViewController()
                let player = AVPlayer(url: videoUrl)
                playerController.player = player
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                present(playerController, animated: true)
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if let locationItem = mkMessage.locationItem {
                let coordinates = locationItem.location.coordinate
                let vc = LocationViewController(coordinates: coordinates, viewType: .viewer)
                vc.title = "Location"
                navigationController?.pushViewController(vc, animated: true)
            }
            
            if let linkItem = mkMessage.linkItem {
                let vc = SFSafariViewController(url: linkItem.url)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
