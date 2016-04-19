//
//  PostModel.swift
//  Purradise
//
//  Created by Nhat Truong on 4/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

class PostModel: NSObject {
    let creator:NSString?
    let timestamp:NSDate
    let image:UIImage?
    let caption:NSString?
    static var feed:Array<PostModel>?
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        creator = dictionary["creator"] as? String
        image = dictionary["image"] as? UIImage
        caption = dictionary["caption"] as? String
        timestamp = NSDate()
    }

}
