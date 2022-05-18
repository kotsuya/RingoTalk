//
//  UIColor+Extension.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/10.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
