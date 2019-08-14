//
//  MoviePickerTableView.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

protocol MoviePickerViewControllerDelegate {
    func moviePicker(moviePicker: MoviePickerViewController, didPickMovie movie: TMDBMovie?)
}

class MoviePickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellReuseId = "MovieSearchCell"
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as! UITableViewCell
        
        if let releaseYear = movie.releaseYear {
            cell.textLabel!.text = "\(movie.title) (\(releaseYear))"
        } else {
            cell.textLabel!.text = "\(movie.title)"
        }
        
        return cell
        
    }
    
    
    
    // func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    //}
    
    
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    
    // The data for the table
    var movies = [TMDBMovie]()
    
    // The delegate will typically be a view controller, waiting for the Movie Picker
    // to return an movie
    var delegate: MoviePickerViewControllerDelegate?
    
    // The most recent data download task. We keep a reference to it so that it can
    // be canceled every time the search text changes
    var searchTask: URLSessionDataTask?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        self.parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: Selector(("logoutButtonTouchUp")))
        
        /* Configure tap recognizer */
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Dismiss Keyboard
    
    @objc func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return self.movieSearchBar.isFirstResponder
    }
    
    // MARK: - UISearchBarDelegate
    
    /* Each time the search text changes we want to cancel any current download and start a new one */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        /* Cancel the last task */
        if let task = searchTask {
            task.cancel()
        }
        
        /* If the text is empty we are done */
        if searchText == "" {
            movies = [TMDBMovie]()
            movieTableView?.reloadData()
            return
        }
        
        /* New search */
        searchTask = TMDBClient.sharedInstance().getMoviesForSearchString(searchString: searchText, completionHandler: { (movies, error) -> Void in
            self.searchTask = nil
            if let movies = movies {
                self.movies = movies
                DispatchQueue.main.async {
                    self.self.movieTableView!.reloadData()
                }
            }
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movie
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    // MARK: - MoviePickerViewController
    
    func cancel() {
        self.delegate?.moviePicker(moviePicker: self, didPickMovie: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func logoutButtonTouchUp() {
        self.dismiss(animated: true, completion: nil)
    }
}
