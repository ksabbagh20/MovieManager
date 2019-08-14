//
//  TMDBConfig.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//
//  The Config class persists information that is used to build image
//  URL's for TheMovieDB. The constant values below were taken from
//  the site on 1/23/15. Invoking the updateConfig convenience method
//  will download the latest using the initializer below to
//  parse the dictionary.
//
//  We will talk more about persistance in a later course.
//

import Foundation

// MARK: - File Support

private let _documentsDirectoryURL: NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
private let _fileURL: NSURL = _documentsDirectoryURL.appendingPathComponent("TheMovieDB-Context")! as NSURL

// MARK: - Config Class

class TMDBConfig: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        print("eyyyyyyy")
    }
    
    
    /* Default values from 1/12/15 */
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    
    /* Returns the number days since the config was last updated */
    var daysSinceLastUpdate: Int? {
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSince(lastUpdate as Date)) / 60*60*24
        } else {
            return nil
        }
    }
    
    // MARK: - Initialization
    
    override init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let imageDictionary = dictionary[TMDBClient.JSONResponseKeys.ConfigImages] as? [String : AnyObject] {
            
            if let urlString = imageDictionary[TMDBClient.JSONResponseKeys.ConfigBaseImageURL] as? String {
                baseImageURLString = urlString
            } else {return nil}
            
            if let urlString = imageDictionary[TMDBClient.JSONResponseKeys.ConfigSecureBaseImageURL] as? String {
                secureBaseImageURLString = urlString
            } else {return nil}
            
            if let posterSizesArray = imageDictionary[TMDBClient.JSONResponseKeys.ConfigPosterSizes] as? [String] {
                posterSizes = posterSizesArray
            } else {return nil}
            
            if let profileSizesArray = imageDictionary[TMDBClient.JSONResponseKeys.ConfigProfileSizes] as? [String] {
                profileSizes = profileSizesArray
            } else {return nil}
            
            dateUpdated = NSDate()
            
        } else {
            return nil
        }
    }
    
    // MARK: - Update
    
    func updateIfDaysSinceUpdateExceeds(days: Int) {
        
        // If the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        } else {
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        
        TMDBClient.sharedInstance().getConfig() { didSucceed, error in
            
            if let error = error {
                print("Error updating config: \(error.localizedDescription)")
            } else {
                print("Updated Config: \(didSucceed)")
                self.save()
            }
        }
    }
    
    // MARK: - NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObject(forKey: BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObject(forKey: SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObject(forKey: PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObject(forKey: ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObject(forKey: DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encode(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encode(posterSizes, forKey: PosterSizesKey)
        aCoder.encode(profileSizes, forKey: ProfileSizesKey)
        aCoder.encode(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> TMDBConfig? {
        
        if FileManager.default.fileExists(atPath: _fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: _fileURL.path!) as? TMDBConfig
        } else {
            return nil
        }
    }
}
