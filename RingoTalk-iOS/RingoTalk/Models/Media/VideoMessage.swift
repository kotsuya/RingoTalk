//
//  VideoMessage.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import MessageKit
import UIKit

class VideoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 240, height: 240)
    }
}
