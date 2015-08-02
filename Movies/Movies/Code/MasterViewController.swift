//
//  MasterViewController.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit

// Adapted from
// http://www.raywenderlich.com/82599/swift-functional-programming-tutorial
typealias Entry = (Character, [String])

func buildIndex(words: [String]) -> [Entry] {
    func distinct<T: Equatable>(source: [T]) -> [T] {
        var unique = [T]()
        for item in source {
            if !contains(unique, item) {
                unique.append(item)
            }
        }
        return unique
    }
    
    func firstLetter(str: String) -> Character {
        return Character(str.substringToIndex(advance(str.startIndex, 1)).uppercaseString)
    }

    let letters = words.map { word -> Character in
        firstLetter(word)
    }
    let distinctLetters = distinct(letters)
    
    return distinctLetters.map { letter -> Entry in
        return (letter, words.filter { word -> Bool in
            firstLetter(word) == letter
        })
    }
}


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var selectedMovieTitle : String? = nil
    var movies = [Entry]()
    var sections = [String]()
    var diskSpaceAvailable = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "showSettings:")
        self.navigationItem.rightBarButtonItem = addButton
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshMovies:")
        self.navigationItem.leftBarButtonItem = refreshButton

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self,
            selector: "movieListLoaded:",
            name: APIConnectorNotifications.MovieListReady.rawValue,
            object: nil)
        
        center.addObserver(self,
            selector: "currentMovie:",
            name: APIConnectorNotifications.CurrentMovieReceived.rawValue,
            object: nil)
        
        center.addObserver(self,
            selector: "diskSpaceLoaded:",
            name: APIConnectorNotifications.DiskSpaceAvailable.rawValue,
            object: nil)
        
        center.addObserver(self,
            selector: "didBecomeActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        APIConnector.sharedInstance.connect()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedMovieTitle = nil
        APIConnector.sharedInstance.getCurrentMovie()
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
        APIConnector.sharedInstance.getAvailableDiskSpace()
    }
    
    // MARK: - NSNotification handlers
    
    func movieListLoaded(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let remoteMovies = userInfo["data"] as? [String] {
                movies = buildIndex(remoteMovies)
                tableView.reloadData()
        }
    }
    
    func diskSpaceLoaded(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let data = userInfo["data"] as? String {
                diskSpaceAvailable = data
                tableView.reloadData()
        }
    }
    
    func currentMovie(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let data = userInfo["data"] as? String {
                selectedMovieTitle = data
                self.performSegueWithIdentifier("showDetail", sender: self)
        }
    }
    
    func didBecomeActive(notification: NSNotification) {
        APIConnector.sharedInstance.getCurrentMovie()
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            var movie : String = ""
            if let notificationMovie = selectedMovieTitle {
                movie = notificationMovie
            }
            else if let indexPath = self.tableView.indexPathForSelectedRow() {
                let entry = movies[indexPath.section]
                movie = entry.1[indexPath.row]
            }
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            controller.currentMovieName = movie
            controller.detailItem = movie
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return movies.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let entry = movies[section]
        return entry.1.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let entry = movies[indexPath.section]
        let movie = entry.1[indexPath.row]
        cell.textLabel!.text = movie
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let entry = movies[section]
        let title = entry.0
        return String(title)
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == movies.count - 1 {
            return "Disk space available: \(diskSpaceAvailable)"
        }
        return nil
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return movies.map { entry -> String in
            String(entry.0)
        }
    }
}
