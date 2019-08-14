//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import Foundation

class TMDBClient : NSObject {
    
    /* Shared session */
    var session: URLSession
    
    /* Configuration object */
    var config = TMDBConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + TMDBClient.escapedParameters(parameters: mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(url: url as URL)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                _ = TMDBClient.errorForData(data: data as NSData?, response: response, error: error as NSError)
                completionHandler(nil, downloadError as NSError?)
            } else {
                TMDBClient.parseJSONWithCompletionHandler(data: data! as NSData, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForGETImage(size: String, filePath: String, completionHandler: @escaping (_ imageData: NSData?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        /* 1. Set the parameters */
        // There are none...
        
        /* 2/3. Build the URL and configure the request */
        _ = [size, filePath]
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = (baseURL.appendingPathComponent(size)?.appendingPathComponent(filePath))! //URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = URLRequest(url: url)//Nsurl
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if downloadError != nil {
                let newError = TMDBClient.errorForData(data: data as NSData?, response: response, error: downloadError! as NSError)
                completionHandler(nil, newError)
            } else {
                completionHandler(data as NSData?, nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey as AnyObject
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + TMDBClient.escapedParameters(parameters: mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        var jsonifyError: NSError? = nil
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody) //(jsonBody, options: nil, error: jsonifyError)
            print("zobtet")
            
        }catch{
            print ("ma zobtet \(error.localizedDescription)")
        }
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = TMDBClient.errorForData(data: data as NSData?, response: response, error: error as NSError)
                completionHandler(nil, downloadError as NSError?)
            } else {
                TMDBClient.parseJSONWithCompletionHandler(data: data! as NSData, completionHandler: completionHandler)
            }
        }
        
        
        
        /* 7. Start the request */
        task.resume()
        
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)//stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: URLResponse?, error: NSError) -> NSError {
        do {
            if let data = data as? Data {
                if let parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]{
                    //print("success")//JSONSerialization.JSONObjectWithData(data!, options: JSONSerialization.ReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
                    
                    if let errorMessage = parsedResult[TMDBClient.JSONResponseKeys.StatusMessage] as? String {
                        
                        let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                        
                        return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
                    }
                }
                
            }
        }catch{
            print("becareful \(error.localizedDescription)")
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        do{
            let parsedResult: AnyObject? =  try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] as AnyObject?
            print ("success")//JSONSerialization.JSONObjectWithData(data, options: JSONSerialization.ReadingOptions.AllowFragments, error: &parsingError)
            
            if let error = parsingError {
                completionHandler(nil, error)
            } else {
                completionHandler(parsedResult, nil)
            }
        }catch{
            print("you thought\(error.localizedDescription)")
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)//stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> TMDBClient {
        
        struct Singleton {
            static var sharedInstance = TMDBClient()
        }
        
        return Singleton.sharedInstance
    }
}
