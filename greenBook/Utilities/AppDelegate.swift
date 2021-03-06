//
//  AppDelegate.swift
//  greenBook
//
//  Created by Mostafa on 10/31/17.
//  Copyright © 2017 Badeeb. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase
import GooglePlaces
import GoogleMaps
import FacebookCore
import FacebookLogin
import GoogleSignIn
import Fabric
import Crashlytics
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var loginViewController : LoginViewController?
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        loadCategories()
        GMSPlacesClient.provideAPIKey(KEYS.GMSPLacesKey)
        GMSServices.provideAPIKey(KEYS.GMSServiceKey)
        
        Fabric.with([Crashlytics.self])
        FIRApp.configure()
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    

public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    if SDKApplicationDelegate.shared.application(
        app,
        open: url as URL!,
        sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
        annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        ){
        return true
        
    }
    if GIDSignIn.sharedInstance().handle(url,
                                         sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                         annotation: [:]) {
        return true
    }
    
    
    return false
}

public func application(_ application: UIApplication, open url: URL,     sourceApplication: String?, annotation: Any) -> Bool {

    if  SDKApplicationDelegate.shared.application(
        application,
        open: url as URL!,
        sourceApplication: sourceApplication,
        annotation: annotation){
        return true
    }
    if GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,annotation: annotation){
        return true
    }


    return false
}

    func loadCategories() {
        CategoryManager.sharedInistance.loadCategories { (response) in
            if !response.status {
                self.loadCategories()
            }
        }

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
        let notification : Notification = Notification.init(name: Notification.Name.UIApplicationWillEnterForeground)
        NotificationCenter.default.post(notification)

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

