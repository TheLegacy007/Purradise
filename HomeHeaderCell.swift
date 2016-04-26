//
//  HomeHeaderCell.swift
//  Purradise
//
//  Created by Nhat Truong on 4/22/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Parse
import Social

protocol CellDelegator {
    func callSegueFromCell(myData dataobject: AnyObject)
}

class HomeHeaderCell: UITableViewCell {

    @IBOutlet weak var actionImage: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorImage: UIImageView!
    
    static let dateFormatter = NSDateFormatter()
    
    var delegete: CellDelegator!
    
    var homeHeaderCell: PFObject! {
        didSet {
            if let homeHeaderCell = homeHeaderCell {
                
                let type = homeHeaderCell["objectName"] as! String
                let action = homeHeaderCell["requiredAction"] as! String
                let status = homeHeaderCell["wasRescued"] as! Bool
                if status == true {
                    actionImage.image = UIImage(named: "check-mark")
                } else {
                    switch type {
                    case "Dog":
                        switch action {
                        case "Rescue": actionImage.image = UIImage(named: "dog-bone-red")
                        case "Adopt": actionImage.image = UIImage(named: "dog-bone-green")
                        case "Lo&Fo": actionImage.image = UIImage(named: "dog-bone-yellow")
                        case "Other": actionImage.image = UIImage(named: "dog-bone")
                        default: break
                            
                        }
                        
                        
                    case "Cat":
                        switch action {
                        case "Rescue": actionImage.image = UIImage(named: "fish-bone-red")
                        case "Adopt": actionImage.image = UIImage(named: "fish-bone-green")
                        case "Lo&Fo": actionImage.image = UIImage(named: "fish-bone-yellow")
                        case "Other": actionImage.image = UIImage(named: "fish-bone")
                        default: break
                            
                        }
                    case "Other": actionImage.image = nil
                    default: break
                    }

                }
                
                authorLabel.text = homeHeaderCell["authorName"] as? String
//                locationLabel.text = homeHeaderCell["location"] as? String
                let updatedAt = homeHeaderCell.createdAt
                
                HomeCell.dateFormatter.dateFormat = "HH:mm:ss EEE MMM"
//                timestampLabel.text = HomeCell.dateFormatter.stringFromDate(updatedAt!)
                timestampLabel.text = timeElapsed(updatedAt!)

            }
        }
    }
    
    @IBAction func onTapPrivateChat(sender: UIButton) {
        // Create a groupId if needed (of two) and segue to chatVC
        let user1 = PFUser.currentUser()!.username!
        let user2 = homeHeaderCell["authorName"] as! String
        print(user1, user2)
        
        let groupId = Messages.startPrivateChat(user1, user2: user2)
        print("groupId", groupId)
        self.openChat(groupId)

    }
    
    func openChat(groupId: String) {
        self.delegete.callSegueFromCell(myData: groupId)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messagesChatSegue" {
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let groupId = sender as! String
            chatVC.groupId = groupId
            print("chats")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension HomeHeaderCell {
    
    func timeElapsed(date: NSDate) -> String {
        if let days = daysFrom(date) {
            return "\(days) days ago"
        } else if let hours = hoursFrom(date) {
            return "\(hours)h ago"
        } else if let minutes = minutesFrom(date) {
            return "\(minutes)m ago"
        } else {
            return "\(secondsFrom(date))s ago"
        }
    }
    
    func daysFrom(date: NSDate) -> Int? {
        let days = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: NSDate(), options: []).day
        if days == 0 {
            return nil
        } else {
            return days
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

