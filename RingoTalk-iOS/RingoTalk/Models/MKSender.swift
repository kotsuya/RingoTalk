//
//  MKSender.swift
//  Message
//
//  Created by Yoo on 2022/05/14.
//

import Foundation
import MessageKit
import UIKit

struct MKSender: SenderType, Equatable {
    
    var senderId: String
    var displayName: String
}

