//
//  Date+Extension.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/17.
//

import Foundation

extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        // File nameへ日本語が入っちゃうので追加(月、日など)
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func interval(ofComponent comp: Calendar.Component, to date: Date) -> Float {
        let currentCalendar = Calendar.current
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: date),
              let start = currentCalendar.ordinality(of: comp, in: .era, for: self)
        else { return 0.0 }
        
        return Float(end - start)
    }
}

