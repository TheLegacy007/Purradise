//
//  HomeViewController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/9/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse

class HomeViewController: UIViewController, FilterDelegate, CellDelegator, MapDelegate {
    
    
    var cloudData: [PFObject]!
    var refreshControl:UIRefreshControl!
    var searchBar: UISearchBar!

    @IBOutlet weak var tableView: UITableView!
   
    var chatButton: UIBarButtonItem!
    var filterButton: UIBarButtonItem!
    var objectName: String?
    var action: String?
    
    var geoLocation: PFGeoPoint?
    var petImage: UIImage!


    
    let filterSettings = FilterSettings.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatButton = UIBarButtonItem(image: UIImage(named: "chat"), style: .Plain, target: self, action: #selector(HomeViewController.openChatMessages(_:)))
        navigationItem.rightBarButtonItems = [chatButton]
        
        filterButton = UIBarButtonItem(image: UIImage(named: "filter"), style: .Plain, target: self, action: #selector(HomeViewController.openFilter(_:)))
        
        tableView.delegate = self
        tableView.dataSource = self
       tableView.estimatedRowHeight = 530
        tableView.rowHeight = UITableViewAutomaticDimension

        
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

    }
    
    
    
    
    func filterController(filterViewController: FilterViewController, didUpdateFilters filter: [String : AnyObject]) {
        filterSettings.objectName = filter["objectName"] as! String
        filterSettings.requiredAction = filter["requiredAction"] as! String
        filterSettings.gender = filter["gender"] as! String
        filterSettings.geoCurrentLocation = filter["geoLocation"] as! PFGeoPoint
        filterSettings.geoCurrentLocationValid = filter["geoLocationValid"] as! Bool
        filterSettings.geoRadius = filter["geoRadius"] as! Double
        
        print("delegate 2")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messagesChatSegue" {
            let dvc = segue.destinationViewController as! ChatViewController
            let groupId = sender as! String
            dvc.groupId = groupId
            dvc.hidesBottomBarWhenPushed = true;

//            dvc.hidesBottomBarWhenPushed = true    // There is more work to do with UICollectionViewFlowLayout, leave it for tomorrow.

        } else if segue.identifier == "toFilterSegue" {
            let dvc = segue.destinationViewController as! FilterViewController
            dvc.delegate = self
            dvc.filters = filterSettings
            dvc.hidesBottomBarWhenPushed = true;

        } else if segue.identifier == "toMapSegue" {
            let dvc = segue.destinationViewController as! MapViewController
            dvc.geoLocation = geoLocation
            dvc.petImage = petImage
            print("prepare for toMapSegue")
            dvc.hidesBottomBarWhenPushed = true;

        } else if segue.identifier == "messageViewSegue" {
 //           let dvc = segue.destinationViewController as! MessagesViewController
            
        }
        print("prepare for segue")
    }
    
    func refresh(sender: AnyObject) {
        print(sender)
        retrieveCloudData(withFilters: filterSettings)
    }
    
    override func viewWillAppear(animated: Bool) {
        retrieveCloudData(withFilters: filterSettings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveCloudData(withFilters filterSettings: FilterSettings) {
        let query = PFQuery(className: "UserMedia")
        query.orderByDescending("createdAt")
        
        if filterSettings.gender != "All" {
            query.whereKey("gender", equalTo: filterSettings.gender)
        }
        if filterSettings.objectName != "All" {
            query.whereKey("objectName", equalTo: filterSettings.objectName)
        }
        if filterSettings.requiredAction != "All" {
            query.whereKey("requiredAction", equalTo: filterSettings.requiredAction)
        }
        if filterSettings.geoRadius != 30000.0 {
            // To be done
            query.whereKey("geoLocation", nearGeoPoint: filterSettings.geoCurrentLocation, withinKilometers: filterSettings.geoRadius)

        }
        
//                let userGeoPoint = PFGeoPoint(latitude: 10.7726, longitude: 106.698)
//                query.whereKey("geoLocation", nearGeoPoint: userGeoPoint, withinKilometers: 1.0)
        
        query.cachePolicy = .NetworkElseCache
        
        query.findObjectsInBackgroundWithBlock { (object:[PFObject]?, error:NSError?) -> Void in
            if object != nil && object?.count != 0{
                self.cloudData = object!
                print(object)
                self.tableView.reloadData()
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func openChatMessages(sender: UIBarButtonItem){
        print("open chat")
        performSegueWithIdentifier("messageViewSegue", sender: self)
    }
    
    @IBAction func openChatMessagesView(sender: UIBarButtonItem) {
        
    }
    
    
    func openFilter(sender: UIBarButtonItem){
        print("open filter")
        performSegueWithIdentifier("toFilterSegue", sender: self)

    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cloudData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HomeHeaderCell") as! HomeHeaderCell
        
        headerCell.homeHeaderCell = self.cloudData[section] as PFObject
        return headerCell

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! HomeCell
        let userMedia = self.cloudData[indexPath.section] as PFObject
        
        cell.homeCell = userMedia
        
        // add border and color
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.1
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.delegete = self

        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    //MARK: - CellDelegator Method
    
    func callSegueFromCell(myData data: AnyObject) {
        //try not to send self, just to avoid retain cycles(depends on how you handle the code on the next controller)
        self.performSegueWithIdentifier("messagesChatSegue", sender: data)
    }
    
    func mapController(didGetMapData data: [String : AnyObject]) {
        geoLocation = data["geoLocation"] as? PFGeoPoint
        petImage = data["petImage"] as! UIImage
        self.performSegueWithIdentifier("toMapSegue", sender: self)
        print("delegate")

    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        print("begin")
        navigationItem.leftBarButtonItems = [filterButton]
        navigationItem.rightBarButtonItems = []

        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        print("end")
        navigationItem.rightBarButtonItems = [chatButton]
        navigationItem.leftBarButtonItems = []

        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        print("cancel")
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //self.searchTerm = searchBar.text
        print("search")
        
        searchBar.resignFirstResponder()
    }
    
    
}


