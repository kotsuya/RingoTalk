//
//  PhotoMessage.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import MessageKit
import UIKit

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    var localUrl: URL?
    
    init(path: String) {
        self.url = URL(string: path) 
        self.localUrl = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(systemName: "photo")!
        self.size = CGSize(width: 240, height: 240)
    }
}
