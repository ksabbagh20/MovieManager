//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toggleWatchlistButton: UIBarButtonItem!
    @IBOutlet weak var toggleFavoriteButton: UIBarButtonItem!
    
    var movie: TMDBMovie?
    var isFavorite = false
    var isWatchlist = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.isTranslucent = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicator.alpha = 1.0
        self.activityIndicator.startAnimating()
        
        /* Set the UI, then check if the movie is a favorite/watchlist and update the buttons! */
        if let movie = movie {
            
            /* Set the title */
            if let releaseYear = movie.releaseYear {
                self.navigationItem.title = "\(movie.title) (\(releaseYear))"
            } else {
                self.navigationItem.title = "\(movie.title)"
            }
            
            /* Setting some default UI ... */
            posterImageView.image = UIImage(named: "MissingPoster")
            isFavorite = false
            
            /* Is the movie a favorite? */
            TMDBClient.sharedInstance().getFavoriteMovies { movies, error in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isFavorite = true
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if self.isFavorite {
                            self.toggleFavoriteButton.tintColor = nil
                        } else {
                            self.toggleFavoriteButton.tintColor = UIColor.black
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            /* Is the movie on the watchlist? */
            TMDBClient.sharedInstance().getWatchlistMovies { movies, error in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isWatchlist = true
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if self.isWatchlist {
                            self.toggleWatchlistButton.tintColor = nil
                        } else {
                            self.toggleWatchlistButton.tintColor = UIColor.black
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            /* Set the poster image*/
            if let posterPath = movie.posterPath {
                TMDBClient.sharedInstance().taskForGETImage(size: TMDBClient.PosterSizes.DetailPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if imageData != nil{
                        if let image = UIImage(data: imageData as! Data) {
                            DispatchQueue.main.async {
                                self.activityIndicator.alpha = 0.0
                                self.activityIndicator.stopAnimating()
                                self.posterImageView.image = image
                            }
                        }else{
                            self.posterImageView.image = UIImage(named: "MissingPoster")
                            print("poster was  not found")
                        }
                    }else{
                        self.posterImageView.image = UIImage(named: "MissingPoster")
                        print("poster not found")
                    }
                    
                })
            } else {
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    // MARK: - Actions
    @IBAction func toggleFavoriteButtonTouchUp(_ sender: Any) {
        if isFavorite {
            TMDBClient.sharedInstance().postToFavorites(movie: movie!, favorite: false) { status_code, error in
                if let err = error {
                    print(err)
                } else {
                    if status_code == 13 {
                        self.isFavorite = false
                        DispatchQueue.main.async {
                            self.toggleFavoriteButton.tintColor = UIColor.black
                        }
                    } else {
                        print("Unexpected status code \(status_code)")
                    }
                }
            }
        } else {
            TMDBClient.sharedInstance().postToFavorites(movie: movie!, favorite: true) { status_code, error in
                if let err = error {
                    print(err)
                } else {
                    if status_code == 1 || status_code == 12 {
                        self.isFavorite = true
                        DispatchQueue.main.async {
                            self.toggleFavoriteButton.tintColor = nil
                        }
                    } else {
                        print("Unexpected status code \(status_code)")
                    }
                }
            }
        }
    }
    
    //@IBAction func toggleFavoriteButtonTouchUp(sender: AnyObject) {
    
    //}
    
    @IBAction func toggleWatchlistButtonTouchUp(_ sender: Any) {
        if isWatchlist {
            TMDBClient.sharedInstance().postToWatchlist(movie: movie!, watchlist: false) { status_code, error in
                if let err = error {
                    print(err)
                } else {
                    if status_code == 13 {
                        self.isWatchlist = false
                        DispatchQueue.main.async {
                            self.toggleWatchlistButton.tintColor = UIColor.black
                        }
                    } else {
                        print("Unexpected status code \(status_code)")
                    }
                }
            }
        } else {
            TMDBClient.sharedInstance().postToWatchlist(movie: movie!, watchlist: true) { status_code, error in
                if let err = error {
                    print(err)
                } else {
                    if status_code == 1 || status_code == 12 {
                        self.isWatchlist = true
                        DispatchQueue.main.async {
                            self.toggleWatchlistButton.tintColor = nil
                        }
                    } else {
                        print("Unexpected status code \(status_code)")
                    }
                }
            }
        }
    }
    // @IBAction func toggleWatchlistButtonTouchUp(sender: AnyObject) {
    
    //}
}
