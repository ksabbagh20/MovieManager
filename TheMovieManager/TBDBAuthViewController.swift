//
//  TMDBAuthViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved. Migrated to swift 5 by Karim Al Sabbagh 8/2019
//

import UIKit

class TMDBAuthViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlRequest: URLRequest? = nil
    var requestToken: String? = nil
    var completionHandler : ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        self.navigationItem.title = "TheMovieDB Auth"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: Selector(("cancelAuth")))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if urlRequest != nil {
            self.webView.loadRequest(urlRequest! as URLRequest)
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if(webView.request!.url?.absoluteString == "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)/allow") {
            
            self.dismiss(animated: true, completion: { () -> Void in
                self.completionHandler!(true, nil)
            })
        }
    }
    
    func cancelAuth() {
        self.dismiss(animated: true, completion: nil)
    }
}
