//
//  LinkMessage.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/19.
//

import Foundation
import MessageKit

class LinkMessage: NSObject, LinkItem {
    var text: String?
    
    var attributedText: NSAttributedString?
    
    var url: URL
    
    var title: String?
    
    var teaser: String
    
    var thumbnailImage: UIImage
    
    init(urlString: String) {
        self.text = urlString
        self.attributedText = nil
        self.url = URL(string: urlString)!
        self.teaser = urlString
        self.thumbnailImage = UIImage(systemName: "link.circle")!
    }
}
