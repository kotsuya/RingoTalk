//
//  AudioMessage.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {
    var url: URL
    
    var duration: Float
    
    var size: CGSize
    
    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 180, height: 35)
        self.duration = duration
    }
}
