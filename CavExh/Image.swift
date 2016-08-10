//
//  Image.swift
//  CavExh
//
//  Created by Tiago Henriques on 12/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import Foundation

class Image: NSObject, NSCoding{
    
    let title : String
    let id : String
    let imageUrl: String
    let descr: String
    let otherImages: Array<String>
    
    init(title: String, id: String, description: String, image: String, otherImages: Array<String>) {
        self.title = title
        self.id = id
        self.imageUrl = image
        self.descr = description
        self.otherImages = otherImages
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getImageUrl() -> String {
        return imageUrl
    }
    
    func getOtherImages() -> Array<String> {
        return otherImages
    }
    
    func getDes() -> String {
        return descr
    }
    
    func getId() -> String {
        return id
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        
        self.title = decoder.decodeObjectForKey("title") as! String
        self.id = decoder.decodeObjectForKey("id") as! String
        self.imageUrl = decoder.decodeObjectForKey("imageUrl") as! String
        self.descr = decoder.decodeObjectForKey("desc") as! String
        self.otherImages = decoder.decodeObjectForKey("others") as! Array<String>
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.title, forKey: "title")
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.imageUrl, forKey: "imageUrl")
        coder.encodeObject(self.descr, forKey: "desc")
        coder.encodeObject(self.otherImages, forKey: "others")
    }
    
}
