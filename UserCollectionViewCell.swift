//
//  UserCollectionViewCell.swift
//  Purradise
//
//  Created by Nhat Truong on 4/25/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Parse

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petImage: UIImageView!
    var userCell: PFObject! {
        didSet {
            if let userCell = userCell {
                if let media = userCell["media"] {
                    media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                        if let data = data {
                            self.petImage.image = UIImage(data: data)
                        }
                    })
                }
                
            }
        }
    }

}
