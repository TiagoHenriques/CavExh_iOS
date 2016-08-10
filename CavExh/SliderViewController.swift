//
//  SliderViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 10/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit
import Social
import ImageSlideshow

class SliderViewController: UIViewController {

    // ScrollView of the page
    @IBOutlet var scrollView: UIScrollView!
    
    // TextView where the description of the image is posted
    @IBOutlet var desc: UITextView!
    
    // Title of the image
    @IBOutlet var titleImage: UILabel!
    
    // Slideshow element, where the images appear
    @IBOutlet var slideshow: ImageSlideshow!
    
    // Variable to auxiliate the transition to the zoom view
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    // Constraint defining the height of the slideshow
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // Constraint defining the height of the whole view
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    // Name of the photo taken
    var photoName: String!
    
    // Index of the image to be presented
    var photoIndex: Int!
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Defines the presentating style
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        if let photoName = photoName {

            // Gets the details of the image
            self.titleImage.text = singleton.getImageTitleByPos(photoIndex)
            self.desc.text = ""//singleton.getImageDescByPos(photoIndex)
            
            // Defines the slideshow properties
            slideshow.backgroundColor = UIColor.whiteColor()
            slideshow.slideshowInterval = 0.0
            slideshow.pageControlPosition = PageControlPosition.UnderScrollView
            slideshow.pageControl.currentPageIndicatorTintColor = UIColor.blackColor();
            slideshow.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
            
            // Gets the size of the screen
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let screenHeight = screenSize.height
            let screenWidth = screenSize.width
            
            // Defines the height of the slideshow according to the screen size
            // Defines the cell size in order to fill 2 cells if in portrait or 3 if in landscape
            if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                self.heightConstraint.constant = min(screenWidth, screenHeight)-80
                self.viewHeight.constant = min(screenHeight, screenWidth)
            } else {
                self.heightConstraint.constant = max(screenWidth, screenHeight)-80
                self.viewHeight.constant = max(screenHeight, screenWidth)
            }
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
            
            //self.viewHeight.constant = max(screenHeight, screenWidth)

            // Gets the images to be presented in the slideshow
            let otherImages = singleton.getImageOtherImagesSetByPos(photoIndex)
         
            // Images in disk
            if singleton.imagesWereDownloaded() {
                var imageArray = [ImageSource]()
                for aux in 0...2 {
                    let str =  singleton.isImageInDisk("other\(singleton.getImageIdByPos(photoIndex))\(aux)")
                    if !UIDevice.currentDevice().orientation.isLandscape.boolValue {
                        var img = UIImage(contentsOfFile: str)
                        img = img?.imageRotatedByDegrees(90, flip: false)
                        imageArray.append(ImageSource(image: img!))
                    } else {
                        let img = UIImage(contentsOfFile: str)
                        
                        imageArray.append(ImageSource(image: UIImage(contentsOfFile:str)!))
                    }
                }
                slideshow.setImageInputs(imageArray)
            }
            // Images not in disk
            else {
                var imageArray = [AlamofireSource]()
                for img in otherImages {
                    
                    imageArray.append(AlamofireSource(urlString: img)!)
                    
                }
                slideshow.setImageInputs(imageArray)
                if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
                {
                    for item in slideshow.slideshowItems {
                        item.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                    }
                }
            }
            
            // Adds the gesture recognizer for the zoom
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SliderViewController.click))
            slideshow.addGestureRecognizer(recognizer)
        }
        
    }
    
    func orientationChanged()
    {
        // Gets the size of the screen
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            self.heightConstraint.constant = min(screenWidth, screenHeight)-80
            self.viewHeight.constant = min(screenHeight, screenWidth)
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            self.heightConstraint.constant = max(screenWidth, screenHeight)-80
            self.viewHeight.constant = max(screenHeight, screenWidth)
        }
        
        
        // Images in disk
        if singleton.imagesWereDownloaded() {
            var imageArray = [ImageSource]()
            for aux in 0...2 {
                let str =  singleton.isImageInDisk("other\(singleton.getImageIdByPos(photoIndex))\(aux)")
                if !UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
                    var img = UIImage(contentsOfFile: str)
                    img = img?.imageRotatedByDegrees(90, flip: false)
                    imageArray.append(ImageSource(image: img!))
                } else {
                    imageArray.append(ImageSource(image: UIImage(contentsOfFile:str)!))
                }
            }
            slideshow.setImageInputs(imageArray)
        }
        // Images not in disk
        else {
            let otherImages = singleton.getImageOtherImagesSetByPos(photoIndex)
            var imageArray = [AlamofireSource]()
            for img in otherImages {
                imageArray.append(AlamofireSource(urlString: img)!)
            }
            slideshow.setImageInputs(imageArray)
            if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
            {
                for item in slideshow.slideshowItems {
                    item.imageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareFacebook(sender: UIButton) {
        
        // Function to share on facebook
        let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        // Composes the iamge and pre-defined text
        if let url = NSURL(string: Singleton.sharedInstance.getImageDetailNameByPos(photoIndex)) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    vc.setInitialText("What a beautiful cavaquinho!")
                    vc.addImage(UIImage(data: imageData))
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func addFavorites(sender: UIButton) {
        
        // If the user is logged in can add images to his favorites
        if singleton.isUserLoggedIn() {
            singleton.addImageToFavorites(photoIndex)
            let alert = UIAlertController(title: NSLocalizedString("Added Favorites Title", comment: ""), message: NSLocalizedString("Added Favorites Description", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        // If not, a warning is presented to the user
        else {
            let alert = UIAlertController(title: NSLocalizedString("No Login Title", comment: ""), message: NSLocalizedString("No Login Description", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    // ImageSlideShow function that treats the click for zooming the image
    func click() {
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.slideshow.setScrollViewPage(page, animated: false)
        }
        ctr.initialPage = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow);
        ctr.transitioningDelegate = self.transitionDelegate!
        self.presentViewController(ctr, animated: true, completion: nil)
    }

}