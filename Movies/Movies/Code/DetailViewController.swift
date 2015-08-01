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
    var currentVolume : Float = 0.5

    // MARK: - IBAction methods
    
    @IBAction func stopPlayback(sender: AnyObject) {
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { action in
            // Do nothing
        }
        
        let OKAction = UIAlertAction(title: "Yes", style: .Default) { action in
            APIConnector.sharedInstance.stopMovie()
            self.stop()
        }

        let alertController = UIAlertController(title: "Stop Playback of '\(currentMovieName)'",
            message: "Are you sure?",
            preferredStyle: .Alert)
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
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
    
    // MARK: - NSNotification handlers
    
    func movieStopped(notification: NSNotification) {
        self.stop()
    }
    
    func play() {
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        
        let sess = AVAudioSession.sharedInstance()
        sess.addObserver(self,
            forKeyPath: "outputVolume",
            options: NSKeyValueObservingOptions.allZeros,
            context: nil)

        let mpic = MPNowPlayingInfoCenter.defaultCenter()
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentMovieName,
            MPMediaItemPropertyArtist: "Raspberry Pi"
        ]
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self,
            selector: "movieStopped:",
            name: APIConnectorNotifications.MovieStopped.rawValue,
            object: nil)

        APIConnector.sharedInstance.playMovie(currentMovieName)
    }
    
    func stop() {
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        resignFirstResponder()
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        NSNotificationCenter.defaultCenter().removeObserver(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var detailItem: AnyObject? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let detail: AnyObject = detailItem {
            navigationItem.title = detail.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        play();
    }
    
    override func observeValueForKeyPath(keyPath: String,
        ofObject object: AnyObject,
        change: [NSObject : AnyObject],
        context: UnsafeMutablePointer<Void>) {
            let newVolume = (object.valueForKey("outputVolume") as! NSNumber).floatValue
            if newVolume > currentVolume {
                APIConnector.sharedInstance.sendCommand(.VolumeUp)
            }
            else {
                APIConnector.sharedInstance.sendCommand(.VolumeDown)
            }
            currentVolume = newVolume
            println("New volume: \(currentVolume)")
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
                
            case .RemoteControlTogglePlayPause:
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
