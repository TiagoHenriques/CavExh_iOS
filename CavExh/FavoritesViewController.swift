//
//  FavoritesViewController.swift
//  
//
//  Created by Tiago Henriques on 12/04/16.
//
//

import UIKit

class FavoritesViewController: UITableViewController {

    // Favorites structure
    var favorites: [String: Favorite] = [String: Favorite]()
    
    // Navigation bar title
    @IBOutlet weak var favoritesTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTitle.title = NSLocalizedString("Favorites", comment: "")
        
        // Gets the favorites from the Singleton DB
        favorites = Singleton.sharedInstance.getFavorites(self)
        
        clearsSelectionOnViewWillAppear = false
        
        tableView.estimatedRowHeight = 200
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadNewData() {
        // Called when receiving new data
        favorites = Singleton.sharedInstance.getFavorites(self)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesListCell", forIndexPath: indexPath) as! FavoritesViewCell

        // Defines each cell accordingly
        var i: Int = 0
        for myValue  in favorites.values{
            if i == indexPath.row {
                cell.favorite = myValue
            }
            i+=1
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var indexPathToReturn: NSIndexPath?
        
        var favorite: Favorite = Favorite(imageUrl: "", imageId: "")
        
        // Gets the index of the pressed item
        var i: Int = 0
        for myValue  in favorites.values{
            if i == indexPath.row {
                favorite = myValue
            }
            i += 1
        }
        
        // If the cell was expanded, performs the actions to go back to the origin form
        if favorites[favorite.getImageId()]!.expanded {
            favorites[favorite.getImageId()]!.expanded = false
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.tableView(tableView, didDeselectRowAtIndexPath: indexPath)
        }
        // Otherwise, performs the actions to expand the item
        else {
            indexPathToReturn = indexPath
            i=0
            for myValue  in favorites.values{
                if i != indexPath.row {
                    favorites[myValue.getImageId()]!.expanded = false
                }
                i += 1
            }
            favorites[favorite.getImageId()]!.expanded = true
            
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

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            var i: Int = 0
            for myValue  in favorites.values{
                if i == indexPath.row {
                    favorites.removeValueForKey(myValue.getImageId())
                    Singleton.sharedInstance.removeImageFromFavorites(myValue.getImageId())
                }
                i += 1
            }
            self.tableView.reloadData()
        }
    }

}
