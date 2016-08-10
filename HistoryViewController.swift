//
//  HistoryViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 12/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    // Image of the history view
    @IBOutlet weak var imageView: UIImageView!
    
    // History text
    @IBOutlet weak var desc: UILabel!
    
   
    // Constraint of the image height
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // Constant of the view height
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    // Title of the navigation view
    @IBOutlet weak var historyTitle: UINavigationItem!
    
    @IBOutlet weak var pageTitle: UILabel!

    
    // Singleton instance
    private var singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Defines the navigation title
        historyTitle.title = NSLocalizedString("History", comment: "")
        
        // Defines the page title (label)
        pageTitle.text = NSLocalizedString("History", comment: "")
        
        // Gets the screen dimensions
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        
        // Defines the size of the image accordingly
        let size = max(screenWidth, screenHeight)/3
        
        // Defines the constraints
        self.viewHeight.constant = max(screenHeight, screenWidth)
        self.heightConstraint.constant = size

        // Gets the history elements with the info
        let history: History = singleton.getHistory()
        
        // Defines the page elements
        let uri = Singleton.sharedInstance.isImageInDisk("history")
        
        // Image not in disk
        if  uri == "" {
            let URL = NSURL(string: history.getImageUrl())!
            imageView.hnk_setImageFromURL(URL)
            
        }
        // Image in disk
        else {
            imageView.image = UIImage(contentsOfFile: uri)
        }

        
        desc.text = history.getDesc()
        desc.sizeToFit()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
