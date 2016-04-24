//
//  UserMedia.swift
//  Purradise
//
//  Created by Nguyen T Do on 4/11/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import Parse

class UserMedia: NSObject {

    // Method to post user media to Parse by uploading image file
    class func postUserImage(imageArray: [UIImage]?, withObjectName objectName: String?, withRequiredAction requiredAction: String?, withLocation location: String?, withGeoLocation geoLocation: PFGeoPoint?, withGeoLocationValid geoLocationValid: Bool, withDescription description: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let media = PFObject(className: "UserMedia")
        
        // Add relevant fields to the object
//        media["media"] = getPFFileFromImage(image) // PFFile column type
        
        for i in imageArray!.indices {
            let imageData = imageArray![i]
            let imageFile = getPFFileFromImage(imageData)
            media["image\(i)"] = imageFile
        }
        
        media["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        media["authorName"] = PFUser.currentUser()?.username
        media["objectName"] = objectName
        media["requiredAction"] = requiredAction  // Rescue or adopt
        media["location"] = location
        media["geoLocation"] = geoLocation
        media["geoLocationValid"] = geoLocationValid
        media["description"] = description
        media["wasRescued"] = false
        media["wasAdopted"] = false
        media["wasFound"] = false
        media["likesCount"] = 0
        
        // Save object (following function will save the object in Parse asynchronously)
        media.saveInBackgroundWithBlock(completion)
        
    }
    
    // Method to post user media to Parse by uploading image file
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = image.mediumQualityJPEGNSData as NSData? { // choose low to reduce by 1/8
                var imageSize = Float(imageData.length)
                imageSize = imageSize/(1024*1024) // in Mb
                print("Image size is \(imageSize)Mb")
                return PFFile(name: "Image.png", data: imageData)
            }
        }
        return nil
    }
}

extension UIImage {
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}
