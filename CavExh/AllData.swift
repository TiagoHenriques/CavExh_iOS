//
//  AllData.swift
//  CavExh
//
//  Created by Tiago Henriques on 24/05/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import Foundation


class AllData : NSObject, NSCoding {
    
    var images: [Int: Image]
    
    var authors: [String: Author]
    
    var history: History
    
    init (images:[Int: Image], authors:[String: Author], history:History) {
        self.images = images
        self.authors = authors
        self.history = history
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        
        self.images = decoder.decodeObjectForKey("images") as! [Int: Image]
        self.authors = decoder.decodeObjectForKey("authors") as! [String: Author]
        self.history = decoder.decodeObjectForKey("history") as! History
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.images, forKey: "images")
        coder.encodeObject(self.authors, forKey: "authors")
        coder.encodeObject(self.history, forKey: "history")
    }
}