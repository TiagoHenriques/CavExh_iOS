//
//  GameViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 16/05/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import Toast_Swift

private let reuseIdentifier = "GameCell"

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Code of the game
    private let gameCode : String = ""
    
    // Correct answer
    private var correctId : String = ""
    
    // Firebase
    var myRootRef = Firebase(url:"https://radiant-inferno-748.firebaseio.com/")
    
    // Image with the piece of the object
    @IBOutlet weak var imageFragment: UIImageView!
    
    // Collection that has all the images
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare a new game
        let code = singleton.getRandomGameCode();
        
        
        let ref = myRootRef.childByAppendingPath("game").childByAppendingPath(code)
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value)
            
            for (key,subJson):(String, JSON) in json {
                
                // Gets the image from the DB
                if key == "image" {
                    let encodedImageData = subJson.stringValue
                    let imageData:NSData = NSData(base64EncodedString: encodedImageData, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                    let image = UIImage(data: imageData)
                    self.imageFragment.image = image
                }
                else {
                    // Gets the answer
                    self.correctId = subJson.stringValue
                }
            
            }
            }, withCancelBlock: { error in
                print(error.description)
        })

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singleton.getNumberTotalImages()
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GameCollectionViewCell
        
        // Checks if there is a file in disk
        let uri = singleton.isImageInDisk("other\(singleton.getImageIdByPos(indexPath.row))0")
        
        // Image not in disk
        if  uri == "" {
            // Defines the properties of the cell
            let URL = NSURL(string: singleton.getImageOtherImagesSetByPos(indexPath.row)[0])!
            cell.imageView.hnk_setImageFromURL(URL)
            cell.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }
        // Image in disk
        else {
            cell.imageView.image = UIImage(contentsOfFile: uri)
            cell.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }

        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // handle tap events
        if (singleton.getImageIdByPos(indexPath.item)==correctId)
        {
            //TODO correct
            let alert = UIAlertController(title: "Right answer", message: "That's the correct object!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                switch action.style{
                case .Default:
                    self.performSegueWithIdentifier("rightAnswer", sender: self)
                case .Cancel: break
                case .Destructive: break
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            // wrong answer
            self.view.makeToast("Wrong answer! Please try again! ", duration: 2.0, position: .Bottom)
        }
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "rightAnswer" {
            if let managePageViewController = segue.destinationViewController as? ManagePageViewController {
                managePageViewController.currentIndex = singleton.getImagePosById(correctId)
            }
        }
    }
    */
    
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
