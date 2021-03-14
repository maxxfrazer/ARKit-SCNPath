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
        //window.rootViewController = ViewController() //SceneKit Version
        window.rootViewController = RKViewController() //RealityKit Version.
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        deleteTemporaryDirectory()
    }
    
    func deleteTemporaryDirectory(){
        print("Resigning Active")
        print(FileManager.default.temporaryDirectory)
        print(FileManager.default.temporaryDirectory.absoluteURL)
        let fileManager = FileManager()
        do {
            try print("Now deleting:", fileManager.contentsOfDirectory(at: FileManager.default.temporaryDirectory, includingPropertiesForKeys: nil, options: []))
        } catch {
            print(error.localizedDescription)
        }

        do {
            try fileManager.removeItem(at: FileManager.default.temporaryDirectory)
        } catch {
            print("could Not remove tmp item")
            print(error.localizedDescription)
        }
    }
}
