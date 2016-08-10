//
//  ManagePageViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 10/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class ManagePageViewController: UIPageViewController {
    
    // Current index of the view pager
    var currentIndex: Int!
    
    // Singleton instance
    private var singleton = Singleton.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        // Detects if it comes from the gallery or the qrcode
        if singleton.wasCodeReaded() {
            currentIndex = singleton.resetReadCode()
        }
        
        if currentIndex != nil {
        
            // Defines the slider views according to the index
            if let viewController = viewSliderController(currentIndex ?? 0) {
                let viewControllers = [viewController]
                
                setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
                
            }
        }
        
    }
    
    func viewSliderController(index: Int) -> SliderViewController? {
        
        // Defines the page to be presented (photo name and index)
        if let storyboard = storyboard,
            page = storyboard.instantiateViewControllerWithIdentifier("SliderViewController") as? SliderViewController {
            page.photoName = singleton.getImageNameByPos(index)
            page.photoIndex = index
            
            return page
        }
        return nil
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// Extension to the class
extension ManagePageViewController: UIPageViewControllerDataSource {
    
    // Defines the page before the one selected
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? SliderViewController {
            var index = viewController.photoIndex
            guard index != NSNotFound && index != 0 else { return nil }
            index = index - 1
            return viewSliderController(index)
        }
        return nil
    }
    
    // Defines the page after the one selected
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? SliderViewController {
            var index = viewController.photoIndex
            guard index != NSNotFound else { return nil }
            index = index + 1
            guard index != singleton.getNumberTotalImages() else {return nil}
            return viewSliderController(index)
        }
        return nil
    }
    
}
