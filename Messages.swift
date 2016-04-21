//
//  Messages.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/21/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import Foundation
import Parse

class Messages {
    
    class func startPrivateChat(user1: String, user2: String) -> String {
        let id1 = user1
        let id2 = user2
        
        let groupId = (id1 < id2) ? "\(id1)\(id2)" : "\(id2)\(id1)"
        
        createMessageItem(user1, groupId: groupId, description: user2 )
        createMessageItem(user2, groupId: groupId, description: user1)
        
        return groupId
    }
    
    class func createMessageItem(user: String, groupId: String, description: String) {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: user)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil {
                if objects!.count == 0 {
                    let message = PFObject(className: PF_MESSAGES_CLASS_NAME)
                    message[PF_MESSAGES_USER] = user;
                    message[PF_MESSAGES_GROUPID] = groupId;
                    message[PF_MESSAGES_DESCRIPTION] = description;
                    message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                    message[PF_MESSAGES_LASTMESSAGE] = "";
                    message[PF_MESSAGES_COUNTER] = 0
                    message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                    message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        if (error != nil) {
                            print("Messages.createMessageItem save error.")
                            print(error)
                        }
                    })
                }
            } else {
                print("Messages.createMessageItem save error.")
                print(error)
            }
        }
    }
    
    class func deleteMessageItem(message: PFObject) {
        message.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error != nil {
                print("UpdateMessageCounter save error.")
                print(error)
            }
        }
    }
    
    class func updateMessageCounter(groupId: String, lastMessage: String) {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for message in objects as [PFObject]! {
                    let user = message[PF_MESSAGES_USER] as! String
                    if user != PFUser.currentUser()!.username! {
                        message.incrementKey(PF_MESSAGES_COUNTER) // Increment by 1
                        message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                        message[PF_MESSAGES_LASTMESSAGE] = lastMessage
                        message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                        message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                            if error != nil {
                                print("UpdateMessageCounter save error.")
                                print(error)
                            }
                        })
                    }
                }
            } else {
                print("UpdateMessageCounter save error.")
                print(error)
            }
        }
    }
    
    class func clearMessageCounter(groupId: String) {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.whereKey(PF_MESSAGES_USER, equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for message in objects as [PFObject]! {
                    message[PF_MESSAGES_COUNTER] = 0
                    message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        if error != nil {
                            print("ClearMessageCounter save error.")
                            print(error)
                        }
                    })
                }
            } else {
                print("ClearMessageCounter save error.")
                print(error)
            }
        }
    }
    
}
