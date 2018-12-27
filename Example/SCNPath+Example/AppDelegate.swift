//
//  AppDelegate.swift
//  SCNPath+Example
//
//  Created by Max Cobb on 12/27/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = ViewController()
		window.makeKeyAndVisible()
		self.window = window
		return true
	}
}
