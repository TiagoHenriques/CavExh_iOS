//
//  OptionsViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 17/05/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    // switch with the gallery has names option
    @IBOutlet weak var hasNamesOption: UISwitch!
    
    // Navigation title
    @IBOutlet weak var optionsTitle: UINavigationItem!
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Defines the navigation title
        optionsTitle.title = NSLocalizedString("Options", comment: "")
        
        // Defines de switch value accordingly
        if singleton.galleryWithNames() {
            hasNamesOption.setOn(true, animated: true)
        }
        else {
            hasNamesOption.setOn(false, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadImage(sender: UIButton) {
        
        // Checks if there is a newer version available
        if singleton.newVersionAvailable() {
            singleton.saveImagesToDisk()
        }
        else {
            self.view.makeToast("You already have the latest version available on your device! ", duration: 2.0, position: .Bottom)
        }
        
        
    }
    
    @IBAction func switchClicked(sender: UISwitch) {
        
        // Acts accordingly as the user changes the switch value
        if hasNamesOption.on {
            singleton.setGalleryHasNamesValue(true)
        }
        else {
            singleton.setGalleryHasNamesValue(false)
        }
        let preferences = NSUserDefaults.standardUserDefaults()
        
        let currentLevelKey = "galleryNames"
        
        preferences.setBool(hasNamesOption.on, forKey: currentLevelKey)
        
        //  Save to disk
        let didSave = preferences.synchronize()
        
        if !didSave {
            print("Wrote to disk")
        }
    }
}
