//
//  Singleton.swift
//  CavExh
//
//  Created by Tiago Henriques on 07/04/16.
//  Copyright © 2016 Tiago Henriques. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import FBSDKLoginKit
import AlamofireImage
import Alamofire

class Singleton {
    
    static let sharedInstance = Singleton()
    
    // Firebase 
    var myRootRef = Firebase(url:"https://radiant-inferno-748.firebaseio.com/")
    
    // Code of the game
    private var qrCodeRead: Bool = false
    private var qrCodeCode: Int = 0
    
    // Images used
    private var images: [Int: Image]
    
    // Authors list
    private var authors: [String: Author]
    
    // History info
    private var history: History
    
    // Favorites
    private var favorites: [String: Favorite]
    
    // Favorites controller
    private var favoritesController: FavoritesViewController
    
    //Games
    private var gameCodes : [String]
    
    // Gallery with names
    private var galleryHasNames : Bool
    
    // Images in disk
    private var imagesInDisk : Bool
    
    // Can the user play the game
    private var gameAvailable : Bool
    
    // Current version of the information on the device
    private var currentVersion: String
    
    // Available version on the DB
    private var versionOnDB : String
    
    // Auth data from the Firebase (with Facebook) login
    private var uid: String
    var accessToken: String
    var userLoggedIn: Bool
    
    init() {
        
        // Get the user preferences
        let preferences = NSUserDefaults.standardUserDefaults()
        
        let currentLevelKey = "galleryNames"
        
        if preferences.objectForKey(currentLevelKey) == nil {
            //  Doesn't exist, default value
            galleryHasNames = true
        } else {
            galleryHasNames = preferences.boolForKey(currentLevelKey)
        }
        
        let currentLevelKey2 = "imagesInDisk"
        
        if preferences.objectForKey(currentLevelKey2) == nil {
            //  Doesn't exist, default value
            imagesInDisk = false
        } else {
            imagesInDisk = preferences.boolForKey(currentLevelKey2)
        }
        
        let currentLevelKey3 = "currentVersion"
        
        if preferences.objectForKey(currentLevelKey3) == nil {
            //  Doesn't exist, default value
            currentVersion = ""
        } else {
            currentVersion = preferences.stringForKey(currentLevelKey3)!
        }

        images = [Int: Image]()
        authors = [String: Author]()
        history = History(imageUrl: "", desc: "")
        favorites = [String: Favorite]()
        favoritesController = FavoritesViewController()
        gameCodes = []
        userLoggedIn=false
        accessToken=""
        uid=""
        gameAvailable = false
        versionOnDB = ""
        
        if (FBSDKAccessToken.currentAccessToken() != nil)  {
            accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            loginFirebase()
            userLoggedIn=true
        }
    }

    func initializeBD(splashView: SplashView) {
        
        if imagesInDisk {
            getdataFromDisk(splashView)
            getGameCodesFromDB()
        }
        else {
            getImagesFromDB(splashView)
            getALFromDB()
            getHistoryFromDB()
            getGameCodesFromDB()
        }
        getVersionFromDB()
    }
    
    func getVersionFromDB () {
        
        // Gets the URL, accordingly to the language
        var url = "https://radiant-inferno-748.firebaseio.com/dbversion"
       
        
        // Firebase part
        let versionDB = Firebase(url: url)
        
        versionDB.observeEventType(.Value, withBlock: { snapshot in
        
            self.versionOnDB = snapshot.value as! String
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func newVersionAvailable() -> Bool {
        return !(versionOnDB==currentVersion)
    }
    
    func getdataFromDisk(splashView: SplashView) {
        
        let ud = NSUserDefaults.standardUserDefaults()
        
        if let data = ud.objectForKey("data") as? NSData {
            let unarc = NSKeyedUnarchiver(forReadingWithData: data)
            let newAllData = unarc.decodeObjectForKey("root") as! AllData
            self.images = newAllData.images
            self.authors = newAllData.authors
            self.history = newAllData.history
        }
        
        splashView.startApp()
    }
    
    func login() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            loginFirebase()
        }
        else {
            loginFirebaseFacebook()
        }
    }
    
    // Method used when the user is already logged in in facebook
    func loginFirebase() {
        // Makes the Firebase login
        let ref = Firebase(url: "https://radiant-inferno-748.firebaseio.com/")
        
        ref.authWithOAuthProvider("facebook", token: self.accessToken,
                                  withCompletionBlock: { error, authData in
                                    if error != nil {
                                        print("Login failed. \(error)")
                                    } else {
                                        self.uid = authData.uid
                                        self.userLoggedIn=true
                                        self.getFavoritesFromDB()
                                    }
        })
    }
    
    // Method used when the facebook login is not yet made
    func loginFirebaseFacebook(){
        
        // Makes the Firebase login
        let ref = Firebase(url: "https://radiant-inferno-748.firebaseio.com/")
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                self.accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                ref.authWithOAuthProvider("facebook", token: self.accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            self.userLoggedIn=true
                            self.uid = authData.uid
                            self.getFavoritesFromDB()
                        }
                })
            }
        })
    }
    
    func isUserLoggedIn() -> Bool {
        return userLoggedIn
    }
    
    func logoutFirebase() {
        uid=""
        userLoggedIn=false
        favorites.removeAll()
        myRootRef.unauth()
    }
    
    func getImagesFromDB(splashView: SplashView) {
        
        // Gets the URL, accordingly to the language
        var url = ""
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String == "pt" {
            url = "https://radiant-inferno-748.firebaseio.com/images_pt_new/list"
        }
        else {
            url = "https://radiant-inferno-748.firebaseio.com/images_new/list"
        }
        
        // Firebase part
        let favs = Firebase(url: url)
        var count: Int = 0
        favs.observeEventType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value)
            
            for (key,subJson):(String, JSON) in json {
                if (subJson["useInApp"].stringValue=="yes") {
                    var arrayOthers: Array<String> = []
 
                    for (_,other):(String, JSON) in subJson["otherImages"] {
                        arrayOthers.append(other["img"].stringValue)
                    }
                
                    let image = Image(title: subJson["title"].stringValue,
                        id: subJson["id"].stringValue,
                        description: subJson["description"].stringValue,
                        image: subJson["imageUrl"].stringValue,
                        otherImages: arrayOthers)
                
                    self.images[count] = image
                    count += 1
                }
            }
            
            splashView.startApp()
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    /**
     * Method that downloads all the images to disk
     *
     **/
    func saveImagesToDisk() {
        
        let ud = NSUserDefaults.standardUserDefaults()
        
        var allData = AllData(images:self.images, authors: self.authors, history: self.history)
        
        // Saves the information
        ud.setObject(NSKeyedArchiver.archivedDataWithRootObject(allData), forKey: "data")
        
        // Saves the object images
        for image in images.values {
            self.downloadImageToDisk(image.getImageUrl(), picName: image.getId())
            // Save the other images
            var aux = 0
            for secImage in image.getOtherImages() {
                self.downloadImageToDisk(secImage, picName: "other\(image.getId())\(aux)")
                aux += 1
            }
        }
        
        // Saves the history image
        self.downloadImageToDisk(history.getImageUrl(), picName: "history")
        
        let preferences = NSUserDefaults.standardUserDefaults()
        
        let currentLevelKey = "imagesInDisk"
        let currentLevelKey2 = "currentVersion"
        
        preferences.setBool(true, forKey: currentLevelKey)
        preferences.setObject(versionOnDB, forKey: currentLevelKey2)
        
        //  Save to disk
        let didSave = preferences.synchronize()
        
        if !didSave {
            print("Wrote to disk")
        }
        imagesInDisk=true
        currentVersion = versionOnDB

    }
    
    func imagesWereDownloaded() -> Bool {
        return imagesInDisk
    }
    
    
    func downloadImageToDisk (imageUrl: String, picName: String) {
        
        //Makes download to NSData
        Alamofire.request(.GET, imageUrl)
            .responseImage { response in
                debugPrint(response)
                
                debugPrint(response.result)
                
                if let image = response.result.value {
                    //Save to disk
                    let fileManager = NSFileManager.defaultManager()
                    
                    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    
                    let filePathToWrite = "\(paths)/\(picName)"
                    
                    // let imageData: NSData = UIImagePNGRepresentation(selectedImage)!
                    let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
                    
                    fileManager.createFileAtPath(filePathToWrite, contents: jpgImageData, attributes: nil)
                    
                    // Check file saved successfully
                    let getImagePath = (paths as NSString).stringByAppendingPathComponent(picName)
                    if (fileManager.fileExistsAtPath(getImagePath))
                    {
                        print("FILE AVAILABLE: \(getImagePath)")
                        
                        //Pick Image and Use accordingly
                        // let imageis: UIImage = UIImage(contentsOfFile: getImagePath)!
                        
                        // let data: NSData = UIImagePNGRepresentation(imageis)
                        
                    }
                    else
                    {
                        print("FILE NOT AVAILABLE: \(getImagePath)")
                        
                    }
                }
        }
    }
    
    func isImageInDisk(picName: String) -> String {
        
        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        // Check file saved successfully
        let getImagePath = (paths as NSString).stringByAppendingPathComponent(picName)
        if (fileManager.fileExistsAtPath(getImagePath))
        {
            print("FILE AVAILABLE: \(getImagePath)")
            return getImagePath
            
            //Pick Image and Use accordingly
            // let imageis: UIImage = UIImage(contentsOfFile: getImagePath)!
            
            // let data: NSData = UIImagePNGRepresentation(imageis)
            
        }
        else
        {
            print("FILE NOT AVAILABLE: \(getImagePath)")
            return ""
        }
    }

    
    func getHistoryFromDB() {
        
        // Gets the URL, accordingly to the language
        var url = ""
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String == "pt" {
            url = "https://radiant-inferno-748.firebaseio.com/history_pt"
        }
        else {
            url = "https://radiant-inferno-748.firebaseio.com/history"
        }
        
        // Firebase part
        let hist = Firebase(url: url)
        
        hist.observeEventType(.Value, withBlock: { snapshot in
            
            let json = JSON(snapshot.value)
            
            self.history = History(imageUrl: json["imageUrl"].stringValue,
                desc: json["text"].stringValue)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func getGameCodesFromDB() {
        
        // Gets the URL, accordingly to the language
        var url = "https://radiant-inferno-748.firebaseio.com/game"
       
        // Firebase part
        let al = Firebase(url: url)
        
        al.observeEventType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value)
            
            for (key,subJson):(String, JSON) in json {
               
                self.gameCodes.append(key)
            }
            self.gameAvailable = true
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func getALFromDB() {
        
        // Gets the URL, accordingly to the language
        var url = ""
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String == "pt" {
            url = "https://radiant-inferno-748.firebaseio.com/authors_pt_new/list"
        }
        else {
            url = "https://radiant-inferno-748.firebaseio.com/authors_new/list"
        }

        // Firebase part
        let al = Firebase(url: url)
        
        al.observeEventType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value)
            
            for (key,subJson):(String, JSON) in json {
                if (subJson["useInApp"].stringValue=="yes") {
                    let author = Author(name: subJson["name"].stringValue,
                        bio: subJson["bio"].stringValue)
                
                    self.authors[author.getName()] = author
                }
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func getFavoritesFromDB() {
        
        let ref = myRootRef.childByAppendingPath("favorites").childByAppendingPath(uid)
        
        favorites.removeAll()
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            let json = JSON(snapshot.value)
            
            for (key,subJson):(String, JSON) in json {
            
                let favorite = Favorite(imageUrl: subJson.stringValue,
                    imageId: key)
                
                if (favorite.getImageUrl() != "") {
                    self.favorites[favorite.getImageId()]=favorite
                }
                
            }
            
            if self.favoritesController.isViewLoaded() {
                self.favoritesController.reloadNewData()
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func getFavorites(favController: FavoritesViewController) -> [String: Favorite] {
        favoritesController = favController
        return favorites
    }
    
    func addImageToFavorites(imageNum: Int) {
        let id = images[imageNum]!.getId()
        let ref = myRootRef.childByAppendingPath("favorites").childByAppendingPath(uid)
        let fav = [id: getImageDetailNameById(id)]
        
        ref.updateChildValues(fav)
    }
    
    func getImageIdByPos(pos: Int) -> String {
        return (images[pos]?.getId())!
    }
    
    func removeImageFromFavorites(id: String) {
        favorites.removeValueForKey(id)
        let ref = myRootRef.childByAppendingPath("favorites").childByAppendingPath(uid)
        ref.childByAppendingPath(id).removeValue()
    }
    
    func getHistory() -> History {
        return history
    }
    
    func getAuthorsList() -> [String: Author] {
        return authors
    }
    
    func getImageById(id: String) -> Image {
        for image in images.values {
            if image.getId()==id {
                return image
            }
        }
        return images.values.first!
    }
    
    func getNumberTotalImages() -> Int {
        return images.count
    }
    
    func getImageNameByPos(pos : Int) -> String {
        return (images[pos]?.getImageUrl())!
    }
    
    func getImageNameByAuthorName(name : String) -> String {
        
        for image in images.values {
            if image.getTitle()==name {
                return image.getImageUrl()
            }
        }
        
        return ""
    }
    
    func getImageIdByAuthorName(name : String) -> String {
        
        for image in images.values {
            if image.getTitle()==name {
                return image.getId()
            }
        }
        
        return ""
    }
    
    func getImageOtherImagesSetByPos(pos : Int) -> Array<String> {
        return (images[pos]?.getOtherImages())!
    }
    
    func getImageTitleByPos(pos: Int) -> String {
        return (images[pos]?.getTitle())!

    }
    
    func getImageDescByPos(pos: Int) -> String {
        return (images[pos]?.getDes())!
        
    }
    
    func getImageDetailNameByPos(pos : Int) -> String {
        let array = images[pos]?.getOtherImages()
        return array![0]
    }
    
    func getImageDetailNameById(id : String) -> String {
        for image in images.values {
            if image.getId()==id {
                let array = image.getOtherImages()
                return array[0]
            }
        }
        return ""
    }
    
    func getImagePosById(id: String) -> Int {
        var count=0
        for image in images.values {
            if image.getId()==id {
                return count
            }
            count += 1
        }
        return 0
    }
    
    func setQRcodeRead(qrcode: Int) {
        qrCodeCode = qrcode
        qrCodeRead = true
    }
    
    
    func wasCodeReaded() -> Bool {
        if qrCodeRead == true {
            return true
        }
        return false
    }
    
    func resetReadCode() -> Int {
        qrCodeRead = false
        return qrCodeCode
    }
    
    func getQRCode() -> Int {
        return qrCodeCode
    }
    
    func getRandomGameCode() -> String {
        
        let res = Int(arc4random_uniform(UInt32(gameCodes.count)));
        
        return gameCodes[res]
    }
    
    func galleryWithNames() -> Bool {
        return galleryHasNames
    }
    
    func setGalleryHasNamesValue(val: Bool) {
        galleryHasNames = val
    }
    
    func isGameAvailable() -> Bool {
        return gameAvailable
    }
    

}
