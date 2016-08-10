//
//  Author.swift
//  CavExh
//
//  Created by Tiago Henriques on 13/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import Foundation

class Author: NSObject, NSCoding {
    
    let name : String
    let bio : String
    var expanded: Bool
    
    init(name: String, bio: String) {
        self.name = name
        self.bio = bio
        self.expanded = false
    }
    
    func getName() -> String {
        return name
    }
    
    func getBio() -> String {
        return bio
    }
    
    // MARK: NSCoding
    
    required init(coder decoder: NSCoder) {
        //Error here "missing argument for parameter name in call
        
        self.name = decoder.decodeObjectForKey("name") as! String
        self.bio = decoder.decodeObjectForKey("bio") as! String
        self.expanded = decoder.decodeBoolForKey("expanded")
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.bio, forKey: "bio")
        coder.encodeBool(self.expanded, forKey: "expanded")
    }
    
}