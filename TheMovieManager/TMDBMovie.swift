//
//  TMDBMovie.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved. Migrated to swift 5 by Karim Al Sabbagh 8/2019
//

struct TMDBMovie {
    
    var title = ""
    var id = 0
    var posterPath: String? = nil
    var releaseYear: String? = nil
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
        
        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String {
            
            if releaseDateString.isEmpty == false {
                let index =  releaseDateString.index(releaseDateString.startIndex, offsetBy: 4)
                releaseYear = String(releaseDateString[index...])
            } else {
                releaseYear = ""
            }
        }
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func moviesFromResults(results: [[String : AnyObject]]) -> [TMDBMovie] {
        var movies = [TMDBMovie]()
        
        for result in results {
            movies.append(TMDBMovie(dictionary: result))
        }
        
        return movies
    }
}



