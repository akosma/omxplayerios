//
//  AppDelegate.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var player : AVAudioPlayer!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure audio session
        let sess = AVAudioSession.sharedInstance()
        sess.setCategory(AVAudioSessionCategoryPlayback, withOptions: nil, error: nil)
        sess.setActive(true, withOptions: nil, error: nil)
        
        // Load a silent file to start playback on the device
        // This is required to get remote control events and to keep the app active in the background
        let path = NSBundle.mainBundle().pathForResource("silence", ofType: "m4a")!
        let fileURL = NSURL(fileURLWithPath: path)
        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        // Play forever, at a very low volume
        player.numberOfLoops = -1
        player.volume = 0
        player.play()

        // iPad related stuff
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        let notif = APIConnectorNotifications.DownloadFinished.rawValue
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "downloadFinished:",
            name: notif,
            object: nil)
        
        let markAsReadAction = UIMutableUserNotificationAction()
        markAsReadAction.identifier = "dismiss"
        markAsReadAction.title = "Dismiss"
        markAsReadAction.activationMode = .Background
        markAsReadAction.destructive = false
        markAsReadAction.authenticationRequired = false

        var actions = UIMutableUserNotificationCategory()
        actions.identifier = "downloadFinished"
        actions.setActions([ markAsReadAction ], forContext: .Minimal)
        actions.setActions([ markAsReadAction ], forContext: .Default)

        let types : UIUserNotificationType = .Alert | .Badge | .Sound
        let categories = NSSet(objects: actions) as? Set<NSObject>
        let settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        return true
    }

    // MARK: - Notification handlers
    
    func downloadFinished(notification: NSNotification) {
        let data = notification.userInfo!
        let url = data["url"] as? String
        let code = data["code"] as? Int
        let not = UILocalNotification()
        not.soundName = UILocalNotificationDefaultSoundName
        not.alertTitle = "Movie Downloaded"
        not.category = "downloadFinished"
        not.fireDate = NSDate()
        not.alertBody = "Download finished: \(url!) with code \(code!)"
        UIApplication.sharedApplication().presentLocalNotificationNow(not)
    }
    
    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController:UIViewController!,
        ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.detailItem == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; 
                    // the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
}
