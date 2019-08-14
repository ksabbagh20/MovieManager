//
//  TMDBConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved. Migrated to swift 5 by Karim Al Sabbagh 8/2019
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension TMDBClient {
    
    // MARK: - Authentication (GET) Methods
    /*
    Steps for Authentication...
    https://www.themoviedb.org/documentation/api/sessions
    
    Step 1: Create a new request token
    Step 2a: Ask the user for permission via the website
    Step 3: Create a session ID
    Bonus Step: Go ahead and get the user id 😎!
    */
    func authenticateWithViewController(hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* Chain completion handlers for each request so that they run one after the other */
        self.getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                self.loginWithToken(requestToken: requestToken, hostViewController: hostViewController) { (success, errorString) in
                    
                    if success {
                        
                        self.getSessionID(requestToken: requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                /* Success! We have the sessionID! */
                                self.sessionID = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            /* And the userID 😄! */
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandler(success, errorString)
                                }
                            } else {
                                completionHandler(success, errorString)
                            }
                        }
                    } else {
                        completionHandler(success, errorString)
                    }
                }
            } else {
                completionHandler(success, errorString)
            }
        }
    }
    
    func getRequestToken(completionHandler: @escaping (_ success: Bool, _ requestToken: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(method: Methods.AuthenticationTokenNew, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print("error \(error.localizedDescription)")
                completionHandler(false, nil, "Login Failed (Request Token).")
            } else {
                print("JSONResult \(JSONResult)")
                if let requestToken = (JSONResult)?.value(forKey: TMDBClient.JSONResponseKeys.RequestToken) as? String {
                    completionHandler(true, requestToken, nil)
                } else {
                    completionHandler(false, nil, "Login Failed (Request Token).")
                }
            }
        }
    }
    
    /* This function opens a TMDBAuthViewController to handle Step 2a of the auth flow */
    func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let authorizationURL = URL(string: "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = URLRequest(url: authorizationURL! as URL)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewController(withIdentifier: "TMDBAuthViewController") as! TMDBAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandler = completionHandler
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        DispatchQueue.main.async {
            
            hostViewController.present(webAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    func getSessionID(requestToken: String?, completionHandler: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.RequestToken : requestToken!]
        
        /* 2. Make the request */
        taskForGETMethod(method: Methods.AuthenticationSessionNew, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(false, nil, "Login Failed (Session ID).")
            } else {
                if let sessionID = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.SessionID) as? String {
                    completionHandler(true, sessionID, nil)
                } else {
                    completionHandler(false, nil, "Login Failed (Session ID).")
                }
            }
        }
    }
    
    func getUserID(completionHandler: @escaping (_ success: Bool, _ userID: Int?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance().sessionID!]
        
        /* 2. Make the request */
        taskForGETMethod(method: Methods.Account, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(false, nil, "Login Failed (User ID).")
            } else {
                if let userID = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.UserID) as? Int {
                    completionHandler(true, userID, nil)
                } else {
                    completionHandler(false, nil, "Login Failed (User ID).")
                }
            }
        }
    }
    
    // MARK: - GET Convenience Methods
    
    func getFavoriteMovies(completionHandler: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID: TMDBClient.sharedInstance().sessionID!]
        var mutableMethod : String = Methods.AccountIDFavoriteMovies
        mutableMethod = TMDBClient.subtituteKeyInMethod(method: mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        taskForGETMethod(method: mutableMethod, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(nil, error)
            } else {
                
                if let results = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results: results)
                    
                    completionHandler(movies, nil)
                } else {
                    completionHandler(nil, NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
                }
            }
        }
    }
    
    func getWatchlistMovies(completionHandler: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID: TMDBClient.sharedInstance().sessionID!]
        var mutableMethod : String = Methods.AccountIDWatchlistMovies
        mutableMethod = TMDBClient.subtituteKeyInMethod(method: mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        taskForGETMethod(method: mutableMethod, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(nil, error)
            } else {
                
                if let results = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
                    
                    var movies = TMDBMovie.moviesFromResults(results: results)
                    
                    completionHandler(movies, nil)
                } else {
                    completionHandler(nil, NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
                }
            }
        }
    }
    
    func getMoviesForSearchString(searchString: String, completionHandler: @escaping (_ result: [TMDBMovie]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.Query: searchString]
        
        /* 2. Make the request */
        let task = taskForGETMethod(method: Methods.SearchMovie, parameters: parameters as [String : AnyObject]) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(nil, error)
            } else {
                
                if let results = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results: results)
                    
                    completionHandler(movies, nil)
                } else {
                    completionHandler(nil, NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
                }
            }
        }
        
        return task
    }
    
    func getConfig(completionHandler: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String: AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(method: Methods.Config, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(false, error)
            } else if let newConfig = TMDBConfig(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(true, nil)
            } else {
                completionHandler(false, NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    
    // MARK: - POST Convenience Methods
    
    func postToFavorites(movie: TMDBMovie, favorite: Bool, completionHandler: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance().sessionID!]
        var mutableMethod : String = Methods.AccountIDFavorite
        mutableMethod = TMDBClient.subtituteKeyInMethod(method: mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance().userID!))!
        let jsonBody : [String:AnyObject] = [
            TMDBClient.JSONBodyKeys.MediaType: "movie" as AnyObject,
            TMDBClient.JSONBodyKeys.MediaID: movie.id as Int as AnyObject,
            TMDBClient.JSONBodyKeys.Favorite: favorite as Bool as AnyObject
        ]
        
        /* 2. Make the request */
        let task = taskForPOSTMethod(method: mutableMethod, parameters: parameters as [String : AnyObject], jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.StatusCode) as? Int {
                    completionHandler(results, nil)
                } else {
                    completionHandler(nil, NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                }
            }
        }
    }
    
    func postToWatchlist(movie: TMDBMovie, watchlist: Bool, completionHandler: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance().sessionID!]
        var mutableMethod : String = Methods.AccountIDWatchlist
        mutableMethod = TMDBClient.subtituteKeyInMethod(method: mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance().userID!))!
        let jsonBody : [String:AnyObject] = [
            TMDBClient.JSONBodyKeys.MediaType: "movie" as AnyObject,
            TMDBClient.JSONBodyKeys.MediaID: movie.id as Int as AnyObject,
            TMDBClient.JSONBodyKeys.Watchlist: watchlist as Bool as AnyObject
        ]
        
        /* 2. Make the request */
        let task = taskForPOSTMethod(method: mutableMethod, parameters: parameters as [String : AnyObject], jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = (JSONResult)?.value(forKey:TMDBClient.JSONResponseKeys.StatusCode) as? Int {
                    completionHandler(results, nil)
                } else {
                    completionHandler(nil, NSError(domain: "postToWatchlist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToWatchlist"]))
                }
            }
        }
    }
}
