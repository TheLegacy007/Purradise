//
//  HomeCell.swift
//  Purradise
//
//  Created by Nhat Truong on 4/9/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import Parse
import Social

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var requiredActionLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var petImage: UIImageView!
    
    static let dateFormatter = NSDateFormatter()
    
   
    
    var homeCell: PFObject! {
        didSet {
            if let homeCell = homeCell {
                authorNameLabel.text = homeCell["authorName"] as? String
                locationLabel.text = homeCell["location"] as? String
                print(homeCell["likesCount"])
                likesCountLabel.text = String(homeCell["likesCount"])
                let media = homeCell["media"] as! PFFile
                let updatedAt = homeCell.updatedAt
                HomeCell.dateFormatter.dateFormat = "HH:mm:ss EEE MMM"
                timestampLabel.text = HomeCell.dateFormatter.stringFromDate(updatedAt!)
                
                let requiredAction = homeCell["requiredAction"] as! NSString
                print(requiredAction)
                switch requiredAction {
                    case "Adopt": requiredActionLabel.text = "\(authorNameLabel.text!) has this for adoption."
                    case "Rescue": requiredActionLabel.text = "\(authorNameLabel.text!) needs you to rescue it."
                    case "Lo&Fo": requiredActionLabel.text = "\(authorNameLabel.text!) has a lost or found pet."
                    case "Other": requiredActionLabel.text = "\(authorNameLabel.text!) has this for other reason."
                    default: break
                }
                
                media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    if let data = data {
                        self.petImage.image = UIImage(data: data)
                    }
                })
            }
            
        }
    }
    
    
    @IBAction func onTapLikeButton(sender: UIButton) {
        // The following implementation is a very simple like button. Further improvement will be done. 
        let query = PFQuery(className:"UserMedia")
        query.getObjectInBackgroundWithId(homeCell.objectId!) { (cloudData: PFObject?, error: NSError?) in
            if error != nil {
                print("Can't get an obj for this cell")
            } else if let cloudData = cloudData {
                var likesCount = cloudData["likesCount"] as! Int
                likesCount += 1
                cloudData["likesCount"] = likesCount
                self.likesCountLabel.text = String(likesCount)
                print(likesCount)
                cloudData.saveInBackground()
            }
        }
    }
    
    @IBAction func onTapFacebookShareButton(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            self.window?.rootViewController?.presentViewController(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Make up Pet's image
        petImage.layer.cornerRadius = 5
        petImage.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension HomeCell {
    
    func timeElapsed(date: NSDate) -> String {
        if let hours = hoursFrom(date) {
            return "\(hours)h"
        } else if let minutes = minutesFrom(date) {
            return "\(minutes)m"
        } else {
            return "\(secondsFrom(date))s"
        }
    }
    
    func hoursFrom(date: NSDate) -> Int? {
        let hours = NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: date, toDate: NSDate(), options: []).hour
        if hours == 0 {
            return nil
        } else {
            return hours
        }
    }
    
    func minutesFrom(date: NSDate) -> Int? {
        let minutes = NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: date, toDate: NSDate(), options: []).minute
        if minutes == 0 {
            return nil
        } else {
            return minutes
        }
    }
    
    func secondsFrom(date: NSDate) -> Int {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Second, fromDate: date, toDate: NSDate(), options: []).second
    }
    
}
