//
//  MTWebViewController.swift
//  umc
//
//  Created by Joseph Radjavitch on 6/10/16.
//  Copyright © 2016 bcgs. All rights reserved.
//

import UIKit
import WebKit

class MTWebViewController: UIViewController {

    let logoImage = "logo_menu"
    
    @IBOutlet fileprivate weak var webView: WKWebView!
    
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backItem?.title = ""
        
//        let image: UIImage = UIImage(named: logoImage)!
//        let imgView = UIImageView(image: image)
//        imgView.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
//        imgView.contentMode = .scaleAspectFit
//        self.navigationItem.titleView = imgView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadURL(_ urlString: String) {
        self.urlString = urlString
    }
}
