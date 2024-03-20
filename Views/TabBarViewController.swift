//
//  TabBarViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 11.03.2024.
//
import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // Create view controllers for each tab
        let firstViewController = HomeViewController()
        let secondViewController = NewsViewController()
        let thirdViewController = ProfileViewController()

        // Set titles for each tab
        firstViewController.title = "Главная"
        secondViewController.title = "Статьи"
        thirdViewController.title = "Профиль"

        // Set tab bar items for each view controller with icons
        firstViewController.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_selected"))
        secondViewController.tabBarItem = UITabBarItem(title: "Статьи", image: UIImage(named: "chat"), selectedImage: UIImage(named: "chat_selected"))
        thirdViewController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "user"), selectedImage: UIImage(named: "user_selected"))

        // Set view controllers for the tab bar controller
        self.viewControllers = [firstViewController, secondViewController, thirdViewController]
        
        // Set default tab bar item tint color
        tabBar.tintColor = UIColor(named: "SecondaryColor")
    }
}

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBarController = TabBarViewController()
        setViewControllers([tabBarController], animated: false)
    }
}
