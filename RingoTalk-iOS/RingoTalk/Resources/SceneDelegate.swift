//
//  SceneDelegate.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/06.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
                
        resetBadge()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        resetBadge()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
        resetBadge()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        resetBadge()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
        resetBadge()
    }
    
    private func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

}

