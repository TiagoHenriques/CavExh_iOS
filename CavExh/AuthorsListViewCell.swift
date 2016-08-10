//
//  AuthorsListViewCell.swift
//  CavExh
//
//  Created by Tiago Henriques on 13/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit

class AuthorsListViewCell: UITableViewCell {
    
    var author: Author? { didSet { if let cm = author { configureCell(cm) } } }
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var desc: UITextView!
    @IBOutlet var expandablePart: UIStackView!
    @IBOutlet var descHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descHeightConstraint.constant=0.0
        expandablePart.hidden=true
    }

    func configureCell(author: Author) {
        
        let id = Singleton.sharedInstance.getImageIdByAuthorName(author.getName())
        let uri = Singleton.sharedInstance.isImageInDisk(id)
        
        // Image not in disk
        if  uri == "" {
            let URL = NSURL(string: Singleton.sharedInstance.getImageNameByAuthorName(author.getName()))!
            imageCell.hnk_setImageFromURL(URL)
            
        }
        // Image in disk
        else {
            imageCell.image = UIImage(contentsOfFile: uri)
        }
       
        title.text = author.getName()
        desc.text = author.getBio()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Defines the height of the cell opening
        let constant: CGFloat = selected ? 100.0 : 0.0
        
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
