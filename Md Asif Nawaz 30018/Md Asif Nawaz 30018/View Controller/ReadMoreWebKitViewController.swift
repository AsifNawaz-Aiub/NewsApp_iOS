//
//  ReadMoreWebKitViewController.swift
//  Md Asif Nawaz 30018
//
//  Created by BJIT on 16/1/23.
//

import UIKit
import WebKit

class ReadMoreWebKitViewController: UIViewController {

    @IBOutlet weak var webKit: WKWebView!
    var urlString = ""
    var progressBar =  UIProgressView()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 20))
        view.addSubview(progressBar)
        if let url = URL(string: urlString){
            webKit.load( URLRequest(url: url))
            // Load the web page
        
            webKit.load(URLRequest(url: url))

            // Observe the estimatedProgress property of the web view
            webKit.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        }
        progressBar.isHidden = true
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webKit.estimatedProgress)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
