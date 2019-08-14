//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/26/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var loginButton: BorderedButton!
    
    var appDelegate: AppDelegate!
    var session: URLSession!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        /* Get the shared URL session */
        session = URLSession.shared
        
        /* Configure the UI */
        self.configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.debugTextLabel.text = ""
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        TMDBClient.sharedInstance().authenticateWithViewController(hostViewController: self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString: errorString)
            }
        }
    }
    
    // MARK: - LoginViewController
    
    func completeLogin() {
        DispatchQueue.main.async {
            self.debugTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func displayError(errorString: String?) {
        DispatchQueue.main.async {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
            }
        }
    }
    
    func configureUI() {
        /* Configure background gradient */
        self.view.backgroundColor = UIColor.clear
        let colorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.white
        
        /* Configure debug text label */
        debugTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        debugTextLabel.textColor = UIColor.white
        
        // Configure login button
        loginButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        loginButton.highlightedBackingColor = UIColor(red: 0.0, green: 0.298, blue: 0.686, alpha:1.0)
        loginButton.backingColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        loginButton.backgroundColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        loginButton.setTitleColor(UIColor.white, for: [])
    }
}

