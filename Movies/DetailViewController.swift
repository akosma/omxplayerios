//
//  DetailViewController.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var currentMovieName = ""
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBAction func stopPlayback(sender: AnyObject) {
        let alertController = UIAlertController(title: "Stop Playback of '\(currentMovieName)'",
            message: "Are you sure?",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
            // Do nothing
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            APIConnector.sharedInstance.stopMovie()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if let detail: AnyObject = self.detailItem {
            self.navigationItem.title = detail.description
            if let label = self.detailDescriptionLabel {
                label.text = "Currently playing '\(currentMovieName)'"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .RemoteControl {
            switch (event.subtype) {
            case .RemoteControlPlay:
                APIConnector.sharedInstance.sendCommand(.Pause)

            case .RemoteControlNextTrack:
                APIConnector.sharedInstance.sendCommand(.Forward30Seconds)
                
            case .RemoteControlPreviousTrack:
                APIConnector.sharedInstance.sendCommand(.Backward30Seconds)
                
            default:
                break;
            }
        }
    }
}
