//
//  ImageEditTableViewController.swift
//  
//
//  Created by Eric Iacutone on 9/20/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON
import FontAwesome_swift
import MBProgressHUD

class ImageEditTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var imageWordsDict = Dictionary<String, AnyObject>()
    var imageArray:[AnyObject] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func saveToImageEditTableViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! DetailImageTableViewController
        
        let index = "\(detailViewController.index!)"
        
        let editedImageWordString = "\(detailViewController.editedImage!)"
        
        let image = self.imageWordsDict[index]!
        
        let image_id = image["id"] as! String
        
        postImageEdit(image_id, word: editedImageWordString)
        
        self.tableView.reloadData()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = defaults.stringForKey("Email") {
            
            getImages(email)
            
        }
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return imageArray.count
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! UITableViewCell
        
        var image = imageWordsDict[String(indexPath.row)]
        var unwrappedImage = image!
        
        cell.textLabel?.text = unwrappedImage["word"] as! String
        

        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let image = self.imageWordsDict[String(indexPath.row)]
            var unwrappedImage = image!
            
            let image_id = unwrappedImage["id"] as! String
            
            if let email = self.defaults.stringForKey("Email") {
                
                self.hideImage(image_id, email: email)
                
            }

            self.imageArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            
            var path = tableView.indexPathForSelectedRow()
            
            var detailViewController = segue.destinationViewController as! DetailImageTableViewController
            
            detailViewController.index = path?.row
            
            detailViewController.imageArray = self.imageArray as! [String]
            
        }
        
    }
    
    func getImages(email:String) {
        
        loadProgress()
        
        var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
        var images_url = info["ImagesUrl"] as! String
        
        Alamofire.request(.GET, "http://" + images_url, parameters: ["email": email])
            .responseJSON { (req, res, json, error) in
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                if(error != nil) {
                    
                    self.displayAlert("Error in the form", message: "Something went wrong")
                    
                }
                    
                else {
                    
                    var images:JSON = JSON(json!)
                    
                    self.imageArray = []
                    
                    if images["info"] == "You have not uploaded and images." {
                        
                        let message:String = images["info"].stringValue
                        self.displayAlert("There was a problem fetching images", message: message)
                        
                    } else {
                        
                        for (index, image) in images["data"]["images"] {
                            
                            self.imageWordsDict[index] = ["id":image["id"].stringValue,"word":image["word"].stringValue]
                            self.imageArray.append(image["word"].stringValue)
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
        }
    }
    
    func postImageEdit(id:String, word:String) {
        
        loadProgress()
        
        var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
        var edit_image_url = info["EditImageUrl"] as! String
        
        Alamofire.request(.POST, "http://" + edit_image_url, parameters: ["image_id":id, "word":word])
            .responseJSON { (req, res, json, error) in
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                var json = JSON(json!)

                if(json["success"] == false) {
                    
                    let message:String = json["info"].stringValue
                    self.displayAlert("There was a problem editing", message: message)
                    
                } else {
                    
                    if let email = self.defaults.stringForKey("Email") {
                        
                        self.getImages(email)
                        
                    }
                    
                }

        }
        
    }
    
    func hideImage(id:String, email:String) {
        
        loadProgress()
        
        var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
        var hide_image_url = info["HideImageUrl"] as! String
        
        Alamofire.request(.POST, "http://" + hide_image_url, parameters: ["image_id":id, "email":email])
            .responseJSON { (req, res, json, error) in
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                var images = JSON(json!)
                
                if(images["success"] == false) {
                    
                    let message:String = images["info"].stringValue
                    self.displayAlert("There was a problem editing", message: message)
                    
                } else {
                    
                    var images:JSON = JSON(json!)
                    
                    self.imageArray = []
                    
                    if images["info"] == "You have not uploaded and images." {
                        
                        let message:String = images["info"].stringValue
                        self.displayAlert("There was a problem fetching images", message: message)
                        
                    } else {
                        
                        for (index, image) in images["data"]["images"] {
                            
                            self.imageWordsDict[index] = ["id":image["id"].stringValue,"word":image["word"].stringValue]
                            self.imageArray.append(image["word"].stringValue)
                            
                        }

                    }
                    
                }
                
        }
        
    }
    
    func displayAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func loadProgress() {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
    }

}
