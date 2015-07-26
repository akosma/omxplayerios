//
//  APIConnector.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit

enum APIConnectorNotifications : String {
    case MovieListReady = "MovieListReady"
    case MoviePlaying = "MoviePlaying"
    case MovieStopped = "MovieStopped"
    case CommandSent = "CommandSent"
    case CurrentMovieReceived = "CurrentMovieReceived"
}

enum APIConnectorMovieCommands : String {
    case Backward30Seconds = "backward"
    case Backward10Minutes = "backward10"
    case Faster = "faster"
    case Forward30Seconds = "forward"
    case Forward10Minutes = "forward10"
    case Info = "info"
    case Pause = "pause"
    case Slower = "slower"
    case Subtitles = "subtitles"
    case VolumeDown = "voldown"
    case VolumeUp = "volup"
}

class APIConnector: NSObject {
    static let sharedInstance = APIConnector()
    let session = NSURLSession.sharedSession()
    var baseURLString : String {
        get {
            if let preference = NSUserDefaults.standardUserDefaults().stringForKey("server_url") {
                return preference
            }
            let result = "http://192.168.1.128:3000"
            NSUserDefaults.standardUserDefaults().setObject(result, forKey: "server_url")
            return result
        }
    }
    
    func getCurrentMovie() {
        let url = NSURL(string: "\(baseURLString)/current_movie")
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                var error : NSErrorPointer = nil
                if let json = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: error) as? [String : String] {
                        if (error == nil) {
                            var userInfo : [String : String]?
                            if let method = json["method"] {
                                if method == "current_movie" {
                                    userInfo = [
                                        "movieName": json["response"]!
                                    ]
                                }
                            }
                            dispatch_sync(dispatch_get_main_queue(), {
                                var notif = APIConnectorNotifications.CurrentMovieReceived.rawValue
                                NSNotificationCenter.defaultCenter().postNotificationName(notif,
                                    object: self,
                                    userInfo: userInfo)
                            })
                        }
                }
            }
        )
        task.resume()
    }
    
    func getMovieList() {
        let url = NSURL(string: "\(baseURLString)/movies")
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                var error : NSErrorPointer = nil
                if let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: error) {
                        if (error == nil) {
                            let userInfo : [NSObject : AnyObject] = [
                                "data": json!
                            ]
                            dispatch_sync(dispatch_get_main_queue(), {
                                let notif = APIConnectorNotifications.MovieListReady.rawValue
                                NSNotificationCenter.defaultCenter().postNotificationName(notif,
                                    object: self,
                                    userInfo: userInfo)
                            })
                        }
                }
            }
        )
        task.resume()
    }
    
    func playMovie(movie: String) {
        let escapedMovie = movie.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let str = "\(baseURLString)/play/\(escapedMovie)"
        let url = NSURL(string: str)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                if let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: nil) {
                        dispatch_sync(dispatch_get_main_queue(), {
                            let notif = APIConnectorNotifications.MoviePlaying.rawValue
                            NSNotificationCenter.defaultCenter().postNotificationName(notif,
                                object: self)
                        })
                }
            }
        )
        task.resume()
    }
    
    func sendCommand(command: APIConnectorMovieCommands) {
        let str = "\(baseURLString)/command/\(command.rawValue)"
        let url = NSURL(string: str)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                if let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: nil) {
                        dispatch_sync(dispatch_get_main_queue(), {
                            let notif = APIConnectorNotifications.CommandSent.rawValue
                            NSNotificationCenter.defaultCenter().postNotificationName(notif,
                                object: self)
                        })
                }
            }
        )
        task.resume()
    }

    func stopMovie() {
        let str = "\(baseURLString)/stop"
        let url = NSURL(string: str)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                if let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: nil) {
                        dispatch_sync(dispatch_get_main_queue(), {
                            let notif = APIConnectorNotifications.MovieStopped.rawValue
                            NSNotificationCenter.defaultCenter().postNotificationName(notif,
                                object: self)
                        })
                }
            }
        )
        task.resume()
    }
}
