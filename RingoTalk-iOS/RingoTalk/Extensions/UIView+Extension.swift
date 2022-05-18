//
//  UIView+Extension.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit

extension UIView {
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    func circleImage() {
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
    }
    
    func border(with width: CGFloat, uiColor:  UIColor) {
        layer.borderWidth = width
        layer.borderColor = uiColor.cgColor
        layer.masksToBounds = true
    }
    
    func circle() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }
}
