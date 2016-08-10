//
//  FavoritesViewCell.swift
//  CavExh
//
//  Created by Tiago Henriques on 13/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class FavoritesViewCell: UITableViewCell {

    var favorite: Favorite? { didSet { if let cm = favorite { configureCell(cm) } } }
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var desc: UITextView!
    @IBOutlet var descHeightConstraint: NSLayoutConstraint!
    @IBOutlet var expandablePart: UIStackView!
    @IBOutlet var title: UILabel!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descHeightConstraint.constant = 0.0
        expandablePart.hidden=true
    }
    
    // function to congigure the cell
    func configureCell(favorite: Favorite) {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        
        let size = max(screenWidth, screenHeight)/3
        
        self.imageHeight.constant = max(screenHeight, screenWidth)/3-20
        
        let image: Image = Singleton.sharedInstance.getImageById(favorite.getImageId())
        
        let uri = Singleton.sharedInstance.isImageInDisk("other\(image.getId())0")
        
        // Image not in disk
        if  uri == "" {
            let URL = NSURL(string: Singleton.sharedInstance.getImageDetailNameById(image.getId()))
            imageCell.hnk_setImageFromURL(URL!)
            imageCell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        }
        // Image in disk
        else {
            var img = UIImage(contentsOfFile: uri)
            img = img?.imageRotatedByDegrees(180, flip: false)
            imageCell.image = img
        }
        
        desc.text = ""
        title.text = image.getTitle()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let constant: CGFloat = selected ? 50.0 : 0.0
        
        if !animated {
            descHeightConstraint.constant = constant
            expandablePart.hidden = !selected
            
            return
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: [.AllowUserInteraction, .BeginFromCurrentState], animations: {
            self.descHeightConstraint.constant = constant
            self.layoutIfNeeded()
            }, completion: { completed in
                self.expandablePart.hidden = !selected
        })
    }

}
