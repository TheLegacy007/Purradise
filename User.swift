//
//  User.swift
//  Purradise
//
//  Created by Nhat Truong on 4/9/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

class User: NSObject {
    static let userDidLogoutNotification = "UserDidLogout"

    var username: NSString?
    var profileUrl: NSURL?
    var posts:Array<PostModel>
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        username = dictionary["username"] as? String
        profileUrl = dictionary["profileUrl"] as? NSURL
        posts = dictionary["posts"] as! Array<PostModel>
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUserData") as? NSData
                if let userData = userData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let data = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(data, forKey: "currentUserData")
            } else {
                defaults.setObject(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
        }
    }

}
