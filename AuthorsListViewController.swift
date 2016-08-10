//
//  AuthorsListViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 12/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class AuthorsListViewController: UITableViewController {

    // Authors list structure
    var authorsList: [String: Author] = Singleton.sharedInstance.getAuthorsList()
    
    // Navigation bar title
    @IBOutlet weak var alTitle: UINavigationItem!
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alTitle.title = NSLocalizedString("Authors List", comment: "")
        
        // Gets the data from the Singleton DB
        authorsList = Singleton.sharedInstance.getAuthorsList()
        
        clearsSelectionOnViewWillAppear = false
        
        // Estimated row height
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authorsList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCellWithIdentifier("AuthorListCell", forIndexPath: indexPath) as! AuthorsListViewCell
        
        // Defines each cell accordingly
        var i: Int = 0
        for myValue  in authorsList.values{
            if i == indexPath.row {
                cell.author = myValue
            }
            i+=1
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var indexPathToReturn: NSIndexPath?
        
        var author: Author = Author(name: "", bio: "")
        
        // Gets the index of the pressed item
        var i: Int = 0
        for myValue  in authorsList.values{
            if i == indexPath.row {
                author = myValue
            }
            i += 1
        }
        
        // If the cell was expanded, performs the actions to go back to the origin form
        if authorsList[author.getName()]!.expanded {
            authorsList[author.getName()]!.expanded = false
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        }
        // Otherwise, performs the actions to expand the item
        else {
            indexPathToReturn = indexPath
            
            for myValue  in authorsList.values{
                if i != indexPath.row {
                    authorsList[myValue.getName()]!.expanded = false
                }
                i += 1
            }
            authorsList[author.getName()]!.expanded = true
            
        }
        
        return indexPathToReturn
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
