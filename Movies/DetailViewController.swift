//
//  DetailViewController.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class DetailViewController: UIViewController {
    
    var currentMovieName = ""
    var player : AVAudioPlayer!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    // MARK: - IBAction methods
    
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
            UIApplication.sharedApplication().endReceivingRemoteControlEvents()
            self.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pausePlayback(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(.Pause)
    }
    
    @IBAction func backward10Minutes(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(APIConnectorMovieCommands.Backward10Minutes)
    }
    
    @IBAction func backward(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(APIConnectorMovieCommands.Backward30Seconds)
    }
    
    @IBAction func forward(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(APIConnectorMovieCommands.Forward30Seconds)
    }
    
    @IBAction func forward10Minutes(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(APIConnectorMovieCommands.Forward10Minutes)
    }
    
    @IBAction func toggleSubtitles(sender: AnyObject) {
        APIConnector.sharedInstance.sendCommand(APIConnectorMovieCommands.Subtitles)
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
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()

        // Configure audio session
        let sess = AVAudioSession.sharedInstance()
        sess.setCategory(AVAudioSessionCategoryPlayback, withOptions: nil, error: nil)
        sess.setActive(true, withOptions: nil, error: nil)
        
        // Load a silent file to start playback on the device
        // This is required to get remote control events…
        let path = NSBundle.mainBundle().pathForResource("silence", ofType: "m4a")!
        let fileURL = NSURL(fileURLWithPath: path)
        self.player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        // Play forever, at a very low volume
        self.player.numberOfLoops = -1
        self.player.volume = 0.0
        self.player.play()
        
        let mpic = MPNowPlayingInfoCenter.defaultCenter()
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentMovieName,
            MPMediaItemPropertyArtist: "Raspberry Pi"
        ]
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .RemoteControl {
            switch (event.subtype) {
            case .RemoteControlPlay:
                APIConnector.sharedInstance.sendCommand(.Pause)
                
            case .RemoteControlPause:
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
