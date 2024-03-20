//
//  SceneDelegate.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 27.02.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        if !onboardingCompleted {
            let onboardingViewController = OnboardingViewController()
            let navigationController = UINavigationController(rootViewController: onboardingViewController)
            window.rootViewController = navigationController
        } else {
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            if isLoggedIn {
                let tabBarViewController = TabBarViewController()
                let navigationController = UINavigationController(rootViewController: tabBarViewController)
                window.rootViewController = navigationController
            } else {
                let signInViewController = SignInViewController()
                let navigationController = UINavigationController(rootViewController: signInViewController)
                window.rootViewController = navigationController
            }
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}


