//
//  MovieInterfaceController.swift
//  Movies
//
//  Created by Adrian on 27/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import WatchKit
import Foundation
import APIConnector


class MovieInterfaceController: WKInterfaceController {

    @IBOutlet weak var movieTitleLabel: WKInterfaceLabel!
    
    @IBAction func stopMovie() {
        APIConnector.sharedInstance.stopMovie()
        dismissController()
    }
    
    @IBAction func pauseMovie() {
        APIConnector.sharedInstance.sendCommand(.Pause)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let title = context as? String {
            self.movieTitleLabel.setText(title)
            APIConnector.sharedInstance.playMovie(title)
        }
    }
    
    func movieStopped(notification: NSNotification) {
        dismissController()
    }
    
    override func willActivate() {
        super.willActivate()
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self,
            selector: "movieStopped:",
            name: APIConnectorNotifications.MovieStopped.rawValue,
            object: nil)
    }
    
    override func didDeactivate() {
        APIConnector.sharedInstance.stopMovie()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.didDeactivate()
    }
}
