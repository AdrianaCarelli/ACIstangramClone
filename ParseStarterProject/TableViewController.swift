//
//  TableViewController.swift
//  ACIstangramClone
//
//  Created by Adriana Carelli on 14/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    var usernames = [""]
    var userids = [""]
    var isFollowing = ["":false]

    
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        
        let query = PFUser.query()
        
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                      if let user = object as? PFUser {
                        
                    
                    if user.objectId! != PFUser.currentUser()?.objectId {
                        
                        self.usernames.append(user.username!)
                        self.userids.append(user.objectId!)
                        let query = PFQuery(className: "Follower")
                       
                        query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
                        query.whereKey("following", equalTo: user.objectId!)
                        
                        query.findObjectsInBackgroundWithBlock({ (objects, error)->Void in
                            
                            if let objects = objects {
                                
                                if objects.count > 0 {
                                    
                                    self.isFollowing[user.objectId!] = true
                                    
                                } else {
                                    
                                    self.isFollowing[user.objectId!] = false
                                    
                                }
                            }
                            
                            if self.isFollowing.count == self.usernames.count {
                                
                                self.tableView.reloadData()
                                
                                self.refresher.endRefreshing()
                                
                            }
                            
                            
                        })
                        
                }
                        
                }
                    
                    
                }

            }
           
        } )
        
    }

  //  MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        
       
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
        }
        
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
//       
//        if isFollowing[indexPath.row] == false{
//            
//            isFollowing[indexPath.row] = true
//            
//            
//            
//            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            
//            let following = PFObject(className: "Follower")
//            following["following"] = userids[indexPath.row];
//            following["follower"] = PFUser.currentUser()?.objectId
//            following.saveInBackground()
//        }else{
//            
//             isFollowing[indexPath.row] = false
//             cell.accessoryType = UITableViewCellAccessoryType.None
//            
//        }
//        
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            let following = PFObject(className: "Follower")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            
            following.saveInBackground()
            
        } else {
            
            isFollowing[followedObjectId] = false
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            let query = PFQuery(className: "Follower")
            
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                        
                    }
                }
                
                
            })
            
            
            
        }

       
    }


   

    

   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
