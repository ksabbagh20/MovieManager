//
//  ListsTableViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/26/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class WatchlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "WatchlistTableViewCell"
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = movie.title
        cell.imageView!.image = UIImage(named: "Film")
        cell.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        
        if let posterPath = movie.posterPath {
            _ = TMDBClient.sharedInstance().taskForGETImage(size: TMDBClient.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                if imageData != nil {
                    if let image = UIImage(data: imageData! as Data) {
                        DispatchQueue.main.async {
                            cell.imageView!.image = image
                        }
                    } else {
                        print("basically:\(String(describing: error?.localizedDescription))")
                    }
                } else{
                    print("this is the reason\(String(describing: error?.localizedDescription))")
                }
                
            })
        }
        
        return cell
    }
    
    
    var movies: [TMDBMovie] = [TMDBMovie]()
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Create and set the logout button */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: Selector(("logoutButtonTouchUp")))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TMDBClient.sharedInstance().getWatchlistMovies { movies, error in
            if let movies = movies {
                self.movies = movies
                DispatchQueue.main.async {
                    self.moviesTableView.reloadData()
                }
            } else {
                print("Logout failed:\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /* Push the movie detail view */
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - WatchlistViewController
    
    func logoutButtonTouchUp() {
        self.dismiss(animated: true, completion: nil)
    }
}

