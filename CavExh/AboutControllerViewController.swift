//
//  AboutControllerViewController.swift
//  CavExh
//
//  Created by Tiago Henriques on 11/07/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class AboutControllerViewController: UIViewController {

    @IBOutlet weak var tile: UINavigationItem!
    
    @IBOutlet weak var text: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.text = NSLocalizedString("About", comment: "")
        
        text.text = NSLocalizedString("About Desc", comment: "")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
