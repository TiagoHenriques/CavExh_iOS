//
//  Favorite.swift
//  v
//
//  Created by Tiago Henriques on 13/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import Foundation

class Favorite: NSObject {
    
    let imageUrl : String
    let imageId : String
    var expanded: Bool
    
    init(imageUrl: String, imageId: String) {
        self.imageUrl = imageUrl
        self.imageId = imageId
        self.expanded = false
    }
    
    func getImageUrl() -> String {
        return imageUrl
    }
    
    func getImageId() -> String {
        return imageId
    }
    
}