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
import FBSDKShareKit

protocol MapDelegate {
    func mapController(didGetMapData data: [String:AnyObject])
}

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var subdescriptionLabel: UILabel!
    @IBOutlet weak var tiltleSubView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    
    @IBOutlet weak var showDescription: UIImageView!
    @IBOutlet weak var trayView: UIView!
    
    @IBAction func onMapButton(sender: UIButton) {
        var data = [String:AnyObject]()
        data["geoLocation"] = geoLocation
        data["petImage"] = petImage
        
        print("onMap")
        self.openMap(data)


    }
    
    func openMap(data: [String:AnyObject]) {
        self.delegate?.mapController(didGetMapData: data)
    }
    
    
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    var geoLocation: PFGeoPoint!
    var petImage: UIImage!
   
    var delegate: MapDelegate!

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
                geoLocation = homeCell["geoLocation"] as! PFGeoPoint
                descriptionLabel.text = homeCell["description"] as? String
                let location = homeCell["location"] as! String
                let type = homeCell["objectName"] as! String
                switch type {
                    case "Dog": subdescriptionLabel.text = "A cute puppy needs your help at \(location)"
                    case "Cat": subdescriptionLabel.text = "A cute kitty needs your help at \(location)"
                    case "Other": subdescriptionLabel.text = "A cute animal needs your help at \(location)"
                default: break
                }
                
                // Support old database
                if let media = homeCell["media"] {
                    media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                        if let data = data {
                            self.slideshow.setImageInputs([ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!)])
                            self.petImage = UIImage(data: data)
                        }
                    })
                }
                
                // New database
                for index in 0...4 {
                    if let media = homeCell["image\(index)"] {
                        media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                            if let data = data {
                                self.slideshow.setImageInputs([ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!)])
                                self.petImage = UIImage(data: data)
                                
                                
                            }
                        })
                    }
                }

            }
            
        }
    }
    
    
    
    func onTapSlideShow() {
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
    
   
    func onTapDescription(sender: UITapGestureRecognizer){
        if self.trayView.center == self.trayCenterWhenClosed {
            self.backView.hidden = false

            self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.trayView.center = self.trayCenterWhenOpen

        } else {
            self.backView.hidden = true

            self.backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
            self.trayView.center = self.trayCenterWhenClosed
        }
        

    }
    
    func onPanDescription(sender: UIPanGestureRecognizer){
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let point = sender.locationInView(trayView)
        let translation = sender.translationInView(trayView)
        let velocity = sender.velocityInView(trayView)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.backView.hidden = false
            trayOriginalCenter = trayView.center
            print("Gesture began at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)

            print("Gesture changed at: \(point)")
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(point)")
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                if velocity.y > 0 {
                    self.trayView.center = self.trayCenterWhenClosed
                    self.backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
                    self.backView.hidden = true

                } else if velocity.y == 0 {
                    self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
                }

                }, completion: { (Bool) -> Void in

            })
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Make up Pet's image
        slideshow.clipsToBounds = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(HomeCell.onTapSlideShow))
        slideshow.addGestureRecognizer(recognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeCell.onTapDescription(_:)))
        showDescription.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(HomeCell.onPanDescription(_:)))
        trayView.addGestureRecognizer(panGesture)
        
        trayCenterWhenOpen = CGPoint(x: trayView.center.x, y:trayView.center.y - 350)
        trayCenterWhenClosed = trayView.center
       
        tiltleSubView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        
        backView.hidden = true
        backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        
        trayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0)
        descriptionLabel.textColor = UIColor.whiteColor()
        subdescriptionLabel.textColor = UIColor.whiteColor()
        subdescriptionLabel.sizeToFit()
        
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "<INSERT STRING HERE>")
        content.contentTitle = "<INSERT STRING HERE>"
        content.contentDescription = "<INSERT STRING HERE>"
        content.imageURL = NSURL(string: "<INSERT STRING HERE>")
        
        let shareButton : FBSDKShareButton = FBSDKShareButton()
//        shareButton.setImage(UIImage(named: "share"), forState: .Normal)
//        shareButton.setTitle(nil, forState: .Normal)
        shareButton.center = CGPoint(x: 310, y: 16)
        shareButton.shareContent = content
        trayView.addSubview(shareButton)
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

