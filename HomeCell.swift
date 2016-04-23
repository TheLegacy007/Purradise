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
import ImageSlideshow


class HomeCell: UITableViewCell {
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    var delegete: CellDelegator!

   

    static let dateFormatter = NSDateFormatter()
    
    
    var homeCell: PFObject! {
        didSet {
            if let homeCell = homeCell {
                
                slideshow.backgroundColor = UIColor.whiteColor()
                slideshow.slideshowInterval = 5.0
                slideshow.pageControlPosition = PageControlPosition.InsideScrollView
                slideshow.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor();
                slideshow.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
                
                print(homeCell["likesCount"])
                likesCountLabel.text = String(homeCell["likesCount"])
                let media = homeCell["media"] as! PFFile
                
                
                media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    if let data = data {
                        self.slideshow.setImageInputs([ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!)])

                    }
                })
            }
            
        }
    }
    
    func click() {
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialPage = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow)
        // Uncomment if you want disable the slide-to-dismiss feature
        // self.transitionDelegate?.slideToDismissEnabled = false

        ctr.transitioningDelegate = self.transitionDelegate
        self.window?.rootViewController?.presentViewController(ctr, animated: true, completion: nil)
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
        slideshow.clipsToBounds = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(HomeCell.click))
        slideshow.addGestureRecognizer(recognizer)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

