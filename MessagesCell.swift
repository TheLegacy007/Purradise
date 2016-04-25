//
//  MessagesCell.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/25/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController

class MessagesCell: UITableViewCell {
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    func bindData(message: PFObject) {
        
        descriptionLabel.text = message[PF_MESSAGES_DESCRIPTION] as? String
        lastMessageLabel.text = message[PF_MESSAGES_LASTMESSAGE] as? String
        
        let seconds = NSDate().timeIntervalSinceDate(message[PF_MESSAGES_UPDATEDACTION] as! NSDate)
        timeElapsedLabel.text = Utilities.timeElapsed(seconds)
        let dateText = JSQMessagesTimestampFormatter.sharedFormatter().relativeDateForDate(message[PF_MESSAGES_UPDATEDACTION] as? NSDate)
        if dateText == "Today" {
            timeElapsedLabel.text = JSQMessagesTimestampFormatter.sharedFormatter().timeForDate(message[PF_MESSAGES_UPDATEDACTION] as? NSDate)
        } else {
            timeElapsedLabel.text = dateText
        }
        
        let counter = message[PF_MESSAGES_COUNTER]!.integerValue
        counterLabel.text = (counter == 0) ? "" : "\(counter) new"
    }
    
}
