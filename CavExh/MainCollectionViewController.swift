//
//  MainCollectionViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 07/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit
import Haneke

private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController {
    
    // Menu button
    @IBOutlet var menuButton: UIBarButtonItem!
    
    // Title of the navigation bar
    @IBOutlet weak var barTitle: UINavigationItem!
    
    // Defines the space between cells
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Defines the bar title
        barTitle.title = NSLocalizedString("Gallery", comment: "")
        
        // Defines the button to open the menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Checks if came from qrcode
        if singleton.wasCodeReaded() {
            
            let rowToSelect:NSIndexPath = NSIndexPath(forRow: singleton.getQRCode(), inSection: 0)
            self.collectionViewLayout.collectionView?.selectItemAtIndexPath(rowToSelect, animated: true, scrollPosition: .None)
            self.performSegueWithIdentifier("showPhotoPage", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singleton.getNumberTotalImages()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridViewCell
        
        // Defines the properties of the cell
        cell.labelCell.text =  singleton.getImageTitleByPos(indexPath.row)
        
        if !singleton.galleryWithNames() {
            cell.labelCell.textColor = UIColor.whiteColor()
        }
        
        let uri = singleton.isImageInDisk(Singleton.sharedInstance.getImageIdByPos(indexPath.row))
        
        // Image not in disk
        if  uri == "" {
            let URL = NSURL(string: Singleton.sharedInstance.getImageNameByPos(indexPath.row))!
            cell.imageCell.hnk_setImageFromURL(URL)

        }
        // Image in disk
        else {
            cell.imageCell.image = UIImage(contentsOfFile: uri)
        }
        
        
        return cell
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        // Caled to force the change of cell size when rotating the devide
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.collectionView!.performBatchUpdates(nil, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView,
                                   layout collectionViewLayout: UICollectionViewLayout,
                                          sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // Gets the screen dimensions
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        var size = screenWidth/2-15
        
        // Defines the cell size in order to fill 2 cells if in portrait or 3 if in landscape
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            size = max(screenWidth, screenHeight)/3-10
        } else {
            size = min(screenWidth, screenHeight)/2-10
        }
        
        return  CGSize(width: size, height: size)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // When a cell is pressed, performs the corresponding segue
        if let cell = sender as? UICollectionViewCell,
            indexPath = collectionView?.indexPathForCell(cell),
            managePageViewController = segue.destinationViewController as? ManagePageViewController {
            managePageViewController.currentIndex = indexPath.row
        }
    }

}
