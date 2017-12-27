//
//  AppDelegate.swift
//  ScrollingAlbum
//
//  Created by RippleArc on 12/23/17.
//  Copyright © 2017 RippleArc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let albumViewController =
           window!.rootViewController as! AlbumViewController
        
        // dependency inject the models
        albumViewController.hdPhotoModel = PhotoCollection(photos: [ "barton_nature_area_bridge_hd.JPG", "barton_nature_lake_hd.JPG", "barton_nature_swan_hd.JPG", "bird_hills_nature_tree_hd.JPG", "bird_hills_nature_sunset_hd.JPG", "huron_river_hd.JPG", "bird_hills_nature_foliage_hd.JPG","leslie_park_hd.png", "willowtree_apartment_sunset_hd.jpg", "vertical_strip_hd.png", "winsor_skyline_hd.png","barton_nature_leeve_hd.JPG"])
        
        albumViewController.thumbnailPhotoModel = PhotoCollection(photos: [ "barton_nature_area_bridge.JPG", "barton_nature_lake.JPG", "barton_nature_swan.JPG", "bird_hills_nature_tree.JPG", "bird_hills_nature_sunset.JPG", "huron_river.JPG", "bird_hills_nature_foliage.JPG","leslie_park", "willowtree_apartment_sunset.jpg", "vertical_strip.png",  "winsor_skyline.png", "barton_nature_leeve.JPG"
            ])
        albumViewController.hdFlowLayout = HDFlowLayout()
        albumViewController.thumbnailMasterFlowLayout = ThumbnailMasterFlowLayout()
        albumViewController.thumbnailMasterFlowLayout.accordionAnimationManager = AcoordionAnimationManager()
        albumViewController.debug = false
        return true
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

