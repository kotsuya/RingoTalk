//
//  LocationMessage.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {    
    var location: CLLocation
    
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
