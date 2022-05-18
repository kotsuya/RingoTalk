//
//  UIViewController+Extension.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/11.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "",
                   message: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

enum Alert {
    static func create(title: String? = nil, message: String,
                       okActionTitle: String = "OK",
                       okActionHandler: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: { _ in
            okActionHandler?()
        })
        alertController.addAction(okAction)
        return alertController
    }
}
