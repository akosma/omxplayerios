//
//  MasterViewController.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var movies = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "showSettings:")
        self.navigationItem.rightBarButtonItem = addButton
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshMovies:")
        self.navigationItem.leftBarButtonItem = refreshButton

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "movieListLoaded:",
            name: APIConnectorNotifications.MovieListReady.rawValue,
            object: nil)

        refreshMovies(nil)
    }

    // MARK: - Button event handlers
    
    func showSettings(sender: AnyObject?) {
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }
    
    func refreshMovies(sender: AnyObject?) {
        APIConnector.sharedInstance.getMovieList()
    }
    
    // MARK: - NSNotification handlers
    
    func movieListLoaded(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let data : AnyObject = userInfo["data" as NSObject],
            let remoteMovies = data["response"] as? [String] {
                movies = remoteMovies
                tableView.reloadData()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let movie = movies[indexPath.row]
                APIConnector.sharedInstance.playMovie(movie)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.currentMovieName = movie
                controller.detailItem = movie
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = movies[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
}