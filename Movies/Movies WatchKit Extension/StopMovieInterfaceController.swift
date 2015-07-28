//
//  StopMovieInterfaceController.swift
//  Movies
//
//  Created by Adrian on 28/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import WatchKit
import Foundation


class StopMovieInterfaceController: WKInterfaceController {

    @IBAction func stop() {
        APIConnector.sharedInstance.stopMovie()
        popToRootController()
    }
}
