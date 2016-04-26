//
//  UserCell.swift
//  Purradise
//
//  Created by Nhat Truong on 4/26/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Parse

class UserCell: UITableViewCell {
    var wasAdopted: Bool!
    var wasRescued: Bool!
    var wasFound: Bool!
    @IBOutlet weak var checkBox: UIButton!
    
    @IBAction func onCheckBox(sender: UIButton) {
        
        let query = PFQuery(className:"UserMedia")
        query.getObjectInBackgroundWithId(userCell.objectId!) { (cloudData: PFObject?, error: NSError?) in
            if error != nil {
                print("Can't get an obj for this cell")
            } else if let cloudData = cloudData {
                let status = cloudData["wasRescued"] as! Bool
                cloudData["wasRescued"] = !status
                cloudData["wasAdopted"] = !status
                cloudData["wasFound"] = !status
                cloudData.saveInBackground()
                if status == false {
                    self.checkBox.setImage(UIImage(named: "checked"), forState: .Normal )
                } else {
                    self.checkBox.setImage(UIImage(named: "uncheck"), forState: .Normal )
                    
                }
                print("status ", !status)
            }
            
        }

    }
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var petImage: UIImageView!
    
    var userCell: PFObject! {
        didSet {
            wasRescued = userCell["wasRescued"] as! Bool
            wasAdopted = userCell["wasAdopted"] as! Bool

            wasFound = userCell["wasFound"] as! Bool

            if wasRescued == true || wasFound == true || wasRescued == true {
                checkBox.setImage(UIImage(named: "checked"), forState: .Normal )
            } else {
                checkBox.setImage(UIImage(named: "uncheck"), forState: .Normal )

            }
            if let userCell = userCell {
                descriptionText.text = userCell["description"] as? String
                if let media = userCell["image0"] {
                    media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                        if let data = data {
                           
                            self.petImage.image = UIImage(data: data)
                        }
                    })
                }

            }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        petImage.layer.borderColor = UIColor.whiteColor().CGColor
        petImage.layer.masksToBounds = false
        petImage.layer.cornerRadius = petImage.frame.height/2
        petImage.clipsToBounds = true
        
        petImage.layer.borderWidth = 2.0
        petImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
