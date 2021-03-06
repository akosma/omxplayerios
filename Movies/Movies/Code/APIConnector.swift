//
//  APIConnector.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

enum APIConnectorNotifications : String {
    case MovieListReady = "MovieListReady"
    case DiskSpaceAvailable = "DiskSpaceAvailable"
    case CurrentMovieReceived = "CurrentMovieReceived"
    case NoCurrentMoviePlaying = "NoCurrentMoviePlaying"
    case MoviePlaying = "MoviePlaying"
    case MovieStopped = "MovieStopped"
    case CommandSent = "CommandSent"
    case DownloadFinished = "DownloadFinished"
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
    var socket : SocketIOClient?
    
    // This method is required by the action extension, which has a very
    // lifetime and does not require the whole infrastructure to be loaded.
    func connectAndDownload(url: String) {
        socket = SocketIOClient(socketURL: baseURLString)
        
        socket?.on("welcome") { data, ack in
            println("socket connected, downloading movie")
            self.downloadMovie(url)
        }
        
        socket?.connect()
    }
    
    func connect() {
        socket = SocketIOClient(socketURL: baseURLString)
        
        socket?.on("welcome") { data, ack in
            println("socket connected")
        }
        
        socket?.on("movies") { data, ack in
            println("received 'movies'")
            if let responseArray = data,
                let responseDictionary = responseArray[0] as? [String : AnyObject],
                let movieArray = responseDictionary["response"] as? [String] {
                    let userInfo : [NSObject : NSArray] = [
                        "data": movieArray
                    ]
                    let notif = APIConnectorNotifications.MovieListReady.rawValue
                    NSNotificationCenter.defaultCenter().postNotificationName(notif,
                        object: self,
                        userInfo: userInfo)
            }
        }
        
        socket?.on("disk") { data, ack in
            println("received 'disk'")
            if let responseArray = data,
                let responseDictionary = responseArray[0] as? [String : AnyObject],
                let diskSpace = responseDictionary["response"] as? String {
                    let userInfo : [NSObject : String] = [
                        "data": diskSpace
                    ]
                    let notif = APIConnectorNotifications.DiskSpaceAvailable.rawValue
                    NSNotificationCenter.defaultCenter().postNotificationName(notif,
                        object: self,
                        userInfo: userInfo)
            }
        }
        
        socket?.on("current_movie") { data, ack in
            println("received 'current_movie'")
            if let responseArray = data,
                let responseDictionary = responseArray[0] as? [String : AnyObject],
                let method = responseDictionary["method"] as? String,
                let currentMovie = responseDictionary["response"] as? String {
                    let userInfo : [NSObject : String] = [
                        "data": currentMovie
                    ]
                    var notif = APIConnectorNotifications.CurrentMovieReceived.rawValue
                    if (method == "error") {
                        notif = APIConnectorNotifications.NoCurrentMoviePlaying.rawValue
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(notif,
                        object: self,
                        userInfo: userInfo)
            }
        }
        
        socket?.on("stop") { data, ack in
            println("received 'stop'")
            var notif = APIConnectorNotifications.MovieStopped.rawValue
            NSNotificationCenter.defaultCenter().postNotificationName(notif,
                object: self)
        }
        
        socket?.on("download_finished") { data, ack in
            println("received 'download_finished'")
            if let responseArray = data,
                let responseDictionary = responseArray[0] as? [String : AnyObject],
                let response = responseDictionary["response"] as? [String : AnyObject] {
                    var notif = APIConnectorNotifications.DownloadFinished.rawValue
                    NSNotificationCenter.defaultCenter().postNotificationName(notif,
                        object: self,
                        userInfo: response)
            }
        }
        
        socket?.connect()
    }

    func getMovieList() {
        println("emitting 'movies'")
        socket?.emit("movies")
    }
    
    func getAvailableDiskSpace() {
        println("emitting 'disk'")
        socket?.emit("disk")
    }
    
    func getCurrentMovie() {
        println("emitting 'current_movie'")
        socket?.emit("current_movie")
    }
    
    func playMovie(movie: String) {
        println("emitting 'play \(movie)'")
        socket?.emit("play", movie)
    }
    
    func sendCommand(command: APIConnectorMovieCommands) {
        println("emitting 'command \(command.rawValue)'")
        socket?.emit("command", command.rawValue)
    }

    func stopMovie() {
        println("emitting 'stop'")
        socket?.emit("stop")
    }
    
    func downloadMovie(url: String) {
        println("emitting 'download \(url)'")
        socket?.emit("download", url)
    }
}
