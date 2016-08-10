//
//  SplashView.swift
//  CavExh
//
//  Created by Tiago Henriques on 12/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class SplashView: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets an instance of the DB
        let singl: Singleton = Singleton.sharedInstance
        singl.initializeBD(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        if Singleton.sharedInstance.imagesWereDownloaded() {
            performSegueWithIdentifier("init", sender: nil)
        }
    }
    
    func startApp() {
        performSegueWithIdentifier("init", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
