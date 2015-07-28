//
//  InterfaceController.swift
//  Movies WatchKit Extension
//
//  Created by Adrian on 27/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var moviesTable: WKInterfaceTable!
    var movies = [String]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self,
            selector: "movieListLoaded:",
            name: APIConnectorNotifications.MovieListReady.rawValue,
            object: nil)
        
        center.addObserver(self,
            selector: "currentMovie:",
            name: APIConnectorNotifications.CurrentMovieReceived.rawValue,
            object: nil)

        APIConnector.sharedInstance.connect()
    }

    func movieListLoaded(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let remoteMovies = userInfo["data"] as? [String] {
                movies = remoteMovies
                moviesTable.setNumberOfRows(movies.count, withRowType: "MovieRow")
                
                for (index, movieName) in enumerate(movies) {
                    let row = moviesTable.rowControllerAtIndex(index) as! MovieController
                    row.movieTitleLabel.setText(movieName)
                }
        }
    }

    func currentMovie(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let movieName = userInfo["data"] as? String {
                pushControllerWithName("MovieController", context: movieName)
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String,
        inTable table: WKInterfaceTable,
        rowIndex: Int) -> AnyObject? {
            let movieName = movies[rowIndex]
            return movieName
    }

    override func willActivate() {
        super.willActivate()
        APIConnector.sharedInstance.getMovieList()
        APIConnector.sharedInstance.getCurrentMovie()
    }
}
