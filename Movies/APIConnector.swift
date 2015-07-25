//
//  APIConnector.swift
//  Movies
//
//  Created by Adrian on 25/07/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

import UIKit

enum APIConnectorNotifications: String {
    case MovieListReady = "MovieListReady"
}

class APIConnector: NSObject {
    static let sharedInstance = APIConnector()
    let session = NSURLSession.sharedSession()
    
    func getMovieList() {
        let url = NSURL(string: "http://192.168.1.128:3000/movies")
        let request = NSURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) -> Void in
                if let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.allZeros,
                    error: nil) {
                        
                        let userInfo : [NSObject : AnyObject] = [
                            "data": json!
                        ]
                        let notif = APIConnectorNotifications.MovieListReady.rawValue
                        NSNotificationCenter.defaultCenter().postNotificationName(notif,
                            object: self,
                            userInfo: userInfo)
                }
            }
        )
        task.resume()
    }
}
