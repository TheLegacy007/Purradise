//
//  FilterViewController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/13/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import RWDropdownMenu
import Parse

protocol FilterDelegate: class {
    func filterController(filterViewController: FilterViewController, didUpdateFilters filters: [String:AnyObject])
}


class FilterViewController: UITableViewController {
    
    weak var delegate: FilterDelegate!
    var filters = FilterSettings.init()

//    let sectionHeaders = ["Type","Status","Location", "Category"]
    
    var menuStyle: RWDropdownMenuStyle = .BlackGradient
    
    
    
    @IBAction func onApply(sender: UIBarButtonItem) {
        var filter = [String:AnyObject]()
        filter["objectName"] = filters.objectName
        filter["requiredAction"] = filters.requiredAction
        filter["gender"] = filters.gender
        filter["geoRadius"] = filters.geoRadius

        delegate?.filterController(self, didUpdateFilters: filter)

        navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
       tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let Types: [RWDropdownMenuItem] =
            [RWDropdownMenuItem(text: "Cat", image: nil, action: {
                self.filters.objectName = "Cat"
                tableView.reloadData()
            }),
             RWDropdownMenuItem(text: "Dog", image: nil, action:{
                self.filters.objectName = "Dog"

                tableView.reloadData()
                
             }),
             RWDropdownMenuItem(text: "Other", image: nil, action: {
                self.filters.objectName = "Other"

                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "All", image: nil, action: {
                self.filters.objectName = "All"

                tableView.reloadData()
             })]
        
        let Status: [RWDropdownMenuItem] =
            [RWDropdownMenuItem(text: "Adopt", image: nil, action: {
                self.filters.requiredAction = "Adopt"

                tableView.reloadData()
            }),
             RWDropdownMenuItem(text: "Rescue", image: nil, action: {
                self.filters.requiredAction = "Rescue"

                tableView.reloadData()
            }),
             RWDropdownMenuItem(text: "Lost&Found", image: nil, action: {
                 self.filters.requiredAction = "Lo&Fo"

                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "Other", image: nil, action: {
                 self.filters.requiredAction = "Other"

                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "All", image: nil, action: {
                 self.filters.requiredAction = "All"

                tableView.reloadData()
             })]
        
        let Gender: [RWDropdownMenuItem] =
            [RWDropdownMenuItem(text: "Male", image: nil, action: {
                 self.filters.gender = "Male"
                tableView.reloadData()
            }),
             RWDropdownMenuItem(text: "Female", image: nil, action: {
                 self.filters.gender = "Female"
                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "Spayed/Neutered", image: nil, action: {
                 self.filters.gender = ""
                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "All", image: nil, action: {
                 self.filters.gender = "All"
                tableView.reloadData()
             })]

        let Distance: [RWDropdownMenuItem] =
            [RWDropdownMenuItem(text: "5 KM", image: nil, action: {
                 self.filters.geoRadius = 5000.0
                tableView.reloadData()
            }),
             RWDropdownMenuItem(text: "10 KM", image: nil, action: {
                 self.filters.geoRadius = 10000.0
                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "20 KM", image: nil, action: {
                 self.filters.geoRadius = 20000.0
                tableView.reloadData()
             }),
             RWDropdownMenuItem(text: "All", image: nil, action: {
                 self.filters.geoRadius = 30000.0
                tableView.reloadData()
             })]

        
        switch indexPath.section {
        case 0:
            RWDropdownMenu.presentFromViewController(self, withItems: Types, align: .Center, style: self.menuStyle, navBarImage: nil , completion: nil)
        case 1:
            RWDropdownMenu.presentFromViewController(self, withItems: Gender, align: .Center, style: self.menuStyle, navBarImage: nil, completion:nil)

        case 2:
            RWDropdownMenu.presentFromViewController(self, withItems: Status, align: .Center, style: self.menuStyle, navBarImage: nil, completion:nil)
        case 3:
            RWDropdownMenu.presentFromViewController(self, withItems: Distance, align: .Center, style: self.menuStyle, navBarImage: nil, completion:nil)

        case 4:
            self.filters.objectName = "All"
            self.filters.requiredAction = "All"
            self.filters.gender = "All"
            self.filters.geoRadius = 30000.0
            
            tableView.reloadData()
        default: break
        }
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionHeaders[section]
//    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the background color show through
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PreferencesCell", forIndexPath: indexPath) as! PreferencesCell
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.1
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Type"
            cell.detailTextLabel?.text = filters.objectName

            switch self.filters.objectName {
            case "All":
                cell.detailTextLabel?.text = "All"
            case "Cat":
                cell.detailTextLabel?.text = "Cat"
            case "Dog":
                cell.detailTextLabel?.text = "Dog"
            default:
                cell.detailTextLabel?.text = "Other"
            }
        case 1:
            cell.textLabel?.text = "Gender"
            cell.detailTextLabel?.text = filters.gender

            switch self.filters.gender {
            case "All":
                cell.detailTextLabel?.text = "All"
            case "Male":
                cell.detailTextLabel?.text = "Male"
            case "Female":
                cell.detailTextLabel?.text = "Female"
            default:
                cell.detailTextLabel?.text = "Spayed/Neutered"
            }

        case 2:
            cell.textLabel?.text = "Status"
            cell.detailTextLabel?.text = filters.requiredAction

            switch self.filters.requiredAction {
            case "All":
                cell.detailTextLabel?.text = "All"
            case "Adopt":
                cell.detailTextLabel?.text = "Adopt"
            case "Rescue":
                cell.detailTextLabel?.text = "Rescue"
            case "Lo&Fo":
                cell.detailTextLabel?.text = "Lost&Found"
            default:
                cell.detailTextLabel?.text = "Other"
            }

        case 3:
            cell.textLabel?.text = "Distance"
            cell.detailTextLabel?.text = String(filters.geoRadius)

            switch self.filters.geoRadius {
            case 30000.0:
                cell.detailTextLabel?.text = "All"
            case 5000.0:
                cell.detailTextLabel?.text = "5 KM"
            case 10000.0:
                cell.detailTextLabel?.text = "10 KM"
            default:
                cell.detailTextLabel?.text = "20 KM"
            }

        case 4:
            cell.detailTextLabel?.text = ""
            cell.textLabel?.text = ""
            let resetLabel = UILabel(frame: CGRectMake(0,0,200,30))
            resetLabel.center = CGPoint(x: view.center.x, y: 320)
            resetLabel.text = "Reset"
            resetLabel.textColor = UIColor.redColor()
            resetLabel.textAlignment = NSTextAlignment.Center
            view.addSubview(resetLabel)
        default: break
            
        }

        return cell
    }
    
       /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
