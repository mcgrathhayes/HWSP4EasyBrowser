//
//  ViewController.swift
//  HWSP4EasyBrowser
//
//  Created by Philip Hayes on 6/17/20.
//  Copyright © 2020 PhilipHayes. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    var progressView: UIProgressView!
    
    let urls = ["apple.com", "hackingwithswift.com", "bbc.com", "cnn.com", "foxnews.com", "google.com"]
    
    override func loadView() {
        // Create an instance of Apple's web render and assign the view controller as the delegate
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use a button to select websites from a list
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        // Add observer to enable update of progress bar. Pair with remove observer in larger apps.
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // URL is swift file storage data type
        // let url = URL(string: "https://www.hackingwithswift.com")!
        
        // Wrap the url in a url request
        // webView.load(URLRequest(url: url))
        
        // Enable property on web view which allows swipe from edges
        // webView.allowsBackForwardNavigationGestures = true
    }
    
    @objc func openTapped() {
        
        let alert = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for url in urls {
            alert.addAction(UIAlertAction(title: url, style: .default, handler: openPage))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(alert, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        
        guard let actionTitle = action.title else { return }
        
        guard let url = URL(string: "https://" + actionTitle) else { return }
        
        webView.load(URLRequest(url: url))
        
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // Required when observer is added
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // Decide whether to allow navigation
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for url in urls {
                if host.contains(url) {
                    // allow urls in url list
                    decisionHandler(.allow)
                    return
                }
            }
        }
        // cancel urls not on list
        decisionHandler(.allow)
    }
}

