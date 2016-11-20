//
//  AppDelegate.swift
//  picexif
//
//  Created by Simon on 03/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if FREE
        let apiKey = "efbd1d4e90e1815616532fc672a15fa8"
        #else
        let apiKey = "8e5b33ce1afe71caa2dd195bc52cba6c"
        #endif
        AMapServices.shared().apiKey = apiKey
        
        let appKey = "582066364ad1566b390042c2"
        UMAnalyticsConfig.sharedInstance().appKey = appKey
        #if FREE
        UMAnalyticsConfig.sharedInstance().channelId = "App Store Free"
        #else
        UMAnalyticsConfig.sharedInstance().channelId = "App Store"
        #endif
        MobClick.start(withConfigure: UMAnalyticsConfig.sharedInstance())
        
        let bar = UINavigationBar.appearance()
        bar.barTintColor = UIColor.withRGB(red: 41, green: 40, blue: 45)
        bar.tintColor = UIColor.white
        bar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)
        ]
        return true
    }
    
    func swizzling() {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appBecomeActive"), object: nil, userInfo: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

