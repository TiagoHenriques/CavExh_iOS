//
//  History.swift
//  
//
//  Created by Tiago Henriques on 13/04/16.
//
//

import Foundation

class History: NSObject, NSCoding {
    
    let imageUrl : String
    let desc : String
    
    init(imageUrl: String, desc: String) {
        self.imageUrl = imageUrl
        self.desc = desc
    }
    
    func getImageUrl() -> String {
        return imageUrl
    }
    
    func getDesc() -> String {
        return desc
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        
        self.imageUrl = decoder.decodeObjectForKey("imageU") as! String
        self.desc = decoder.decodeObjectForKey("description") as! String
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.imageUrl, forKey: "imageU")
        coder.encodeObject(self.desc, forKey: "description")
    }
    
}