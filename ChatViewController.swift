//
//  ChatViewController.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/23/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import Parse
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    
    var groupId: String = ""
    
    var users = [String]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var batchMessages = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser() {
            self.senderId = user.username
            self.senderDisplayName = user.username
        }
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profile_blank"), diameter: 30)
        
        isLoading = false
        self.loadMessages()
        Messages.clearMessageCounter(groupId);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // self.collectionView.collectionViewLayout.springinessEnabled = true   // Don't do this, looks like a bug!
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // Mark: - Backend methods
    
    func loadMessages() {
        if self.isLoading == false {
            self.isLoading = true
            let lastMessage = messages.last
            
            let query = PFQuery(className: PF_CHAT_CLASS_NAME)
            query.whereKey(PF_CHAT_GROUPID, equalTo: groupId)
            if let lastMessage = lastMessage {
                query.whereKey(PF_CHAT_CREATEDAT, greaterThan: lastMessage.date)
            }
            // query.includeKey(PF_CHAT_USER)
            query.orderByDescending(PF_CHAT_CREATEDAT)
            query.limit = 50
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in Array((objects as [PFObject]!).reverse()) {
                        self.addMessage(object)
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(true)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                } else {
                    //                    MBProgressHUD.show(MBProgressHUD)
                    //                    ProgressHUD.showError("Network error")
                    print("Network error")
                }
                self.isLoading = false;
            })
        }
    }
    
    func addMessage(object: PFObject) {
        var message: JSQMessage!
        
        let user = object[PF_CHAT_USER] as! String
        let name = object[PF_CHAT_USER] as! String
        
        let pictureFile = object[PF_CHAT_PICTURE] as? PFFile
        
        if pictureFile == nil {
            message = JSQMessage(senderId: user, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String))
        }
        
        if let pictureFile = pictureFile {
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (user == self.senderId)
            message = JSQMessage(senderId: user, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            
            pictureFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData!)
                    self.collectionView.reloadData()
                }
            })
        }
        
        users.append(user)
        messages.append(message)
    }
    
    func sendMessage( text: String, video: NSURL?, picture: UIImage?) {
        var pictureFile: PFFile!
        
        if let picture = picture {
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackgroundWithBlock({ (suceeded: Bool, error: NSError?) -> Void in
                if error != nil {
                    //                    ProgressHUD.showError("Picture save error")
                    print("Picture save error")
                }
            })
        }
        
        let object = PFObject(className: PF_CHAT_CLASS_NAME)
        object[PF_CHAT_USER] = PFUser.currentUser()?.username
        object[PF_CHAT_GROUPID] = self.groupId
        object[PF_CHAT_TEXT] = text
        
        if let pictureFile = pictureFile {
            object[PF_CHAT_PICTURE] = pictureFile
        }
        object.saveInBackgroundWithBlock{ (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            } else {
                //                ProgressHUD.showError("Network error")
                print("Picture save error")
            }
        }
        
        //        PushNotication.sendPushNotification(groupId, text: text)    // NOT NOW
        Messages.updateMessageCounter(groupId, lastMessage: text)
        
        self.finishSendingMessage()
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.sendMessage(text, video: nil, picture: nil)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        self.view.endEditing(true)
        
        let accessoryAction = UIAlertController(title: nil, message: "Choose one", preferredStyle: UIAlertControllerStyle.Alert)
        accessoryAction.addAction(UIAlertAction(title: "Choose existing photo", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        }))
        accessoryAction.addAction(UIAlertAction(title: "Take photo", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: false)
        }))
        accessoryAction.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(accessoryAction, animated: true, completion: nil)
    }
    
    // MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = self.users[indexPath.item]
        self.avatars[user] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "paw"), diameter: 30)
        return self.avatars[user]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: - UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = self.messages[indexPath.item]
        // print("Nguyen debugging", message)
        if message.senderId == self.senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    // MARK: - UICollectionView flow layout
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    // MARK: - Responding to CollectionView tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageview")
    }
    
    //    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
    //        let message = self.messages[indexPath.item]
    //        if message.isMediaMessage {
    //            if let mediaItem = message.media as? JSQVideoMediaItem {
    //                let moviePlayer = MPMoviePlayerViewController(contentURL: mediaItem.fileURL)
    //                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
    //                moviePlayer.moviePlayer.play()
    //            }
    //        }
    //    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.sendMessage("", video: video, picture: picture)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
