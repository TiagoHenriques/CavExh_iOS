//
//  SlideMenuController.swift
//  CavExh
//
//  Created by Tiago Henriques on 12/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SlideMenuController: UITableViewController {
    
    // Label of the login item
    @IBOutlet var loginLabel: UILabel!
    
    // Label of the qrcode item
    //@IBOutlet weak var readCode: UILabel!
    
    // Label of the favorites item
    @IBOutlet weak var favorites: UILabel!
    
    // Label of the authors list item
    @IBOutlet weak var authorsList: UILabel!
    
    // Label of the history item
    @IBOutlet weak var history: UILabel!
    
    // Label of the game item
    @IBOutlet weak var playGame: UILabel!
    
    // Label of the options item
    @IBOutlet weak var optionsLabel: UILabel!
    
    // Label of the about item
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var credits: UILabel!
    
    // Singleton instance
    private let singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        
        // Assigns the text to the labels
        //readCode.text = NSLocalizedString("Read Code", comment: "")
        favorites.text = NSLocalizedString("Favorites", comment: "")
        authorsList.text = NSLocalizedString("Authors List", comment: "")
        history.text = NSLocalizedString("History", comment: "")
        playGame.text = NSLocalizedString("Play Game", comment: "")
        history.text = NSLocalizedString("History", comment: "")
        optionsLabel.text = NSLocalizedString("Options", comment: "")
        aboutLabel.text = NSLocalizedString("About", comment: "")
        credits.text = NSLocalizedString("credits", comment: "")
        
        
        
        // Checks if the user is logged in or not, and assigns label to login item accordingly
        if singleton.isUserLoggedIn() {
            self.loginLabel.text = "Logout"
        }
        else {
            self.loginLabel.text = "Login"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // When item 8 (login) is selected, performs the login or logout, and updates the label text
        if indexPath.row == 8 {
            if singleton.isUserLoggedIn() {
                Singleton.sharedInstance.logoutFirebase()
                self.loginLabel.text = "Login"
            } else {
                singleton.login()
                self.loginLabel.text = "Logout"
            }
            let indexPath = NSIndexPath(forRow: 4, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "game" {
            if singleton.isGameAvailable() {
                return true
            }
            else {
                self.parentViewController?.view.makeToast("You need an internet connection to play! ", duration: 2.0, position: .Bottom)
                return false
            }
        }
        return true
    }

}
