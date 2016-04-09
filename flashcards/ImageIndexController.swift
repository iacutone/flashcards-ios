//
//  ImageController.swift
//  flashcards
//
//  Created by Eric Iacutone on 9/7/15.
//  Copyright (c) 2015 Iacutone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FontAwesome_swift
import MBProgressHUD
//import AlamofireImage

class ImageIndexController: UIViewController {
    
    @IBOutlet var cardView: UIView!
    
    @IBOutlet var tapLabel: UILabel!
    
    @IBOutlet var image: UIImageView!
    
    @IBOutlet var wordLabel: UILabel!
    
    let tapRec = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let defaults = NSUserDefaults.standardUserDefaults()
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0).CGColor
        
        loadProgress()

        if let email = defaults.stringForKey("Email") {
                
            updateImage(email, increment: "0")
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let loggedIn:String! = defaults.stringForKey("userLoggedIn")
        let email:String! = defaults.stringForKey("Email")

        if loggedIn != "loggedIn" || email == nil || email == "" {
            
            segueToSignInController()
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("loggedOut", forKey: "userLoggedIn")
            defaults.synchronize()
            
        }
        
    }
    
    func segueToSignInController() {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        let signInController:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("signInController") as! UIViewController
        
        self.presentViewController(signInController, animated: true, completion: nil)
        
    }
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        let scale = min(100 / abs(xFromCenter), 1)

        var rotation = CGAffineTransformMakeRotation(xFromCenter / 500)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Changed {

            if label.center.x < 145 {
                
                
                
            }
            
            if label.center.x > 215 {
                

                
            }
            
        }
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if label.center.x < 100 {
                
                if let email = defaults.stringForKey("Email") {
                    
                    hideImage()
                    hideWord()
                    updateImage(email, increment: "-1")
                    
                }
                
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                if let email = defaults.stringForKey("Email") {
                    
                    hideImage()
                    hideWord()
                    updateImage(email, increment: "1")
                    
                }
                
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            
            stretch = CGAffineTransformScale(rotation, 1, 1)
            
            label.transform = stretch
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
        }
        
    }
    
    func showWord() {
        
        self.tapLabel.text = ""
        self.wordLabel.textColor = UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0)
        
    }
    
    func hideWord() {
        
        self.wordLabel.text = ""
        self.tapLabel.text = "Tap"
        
    }
    
    func hideImage() {
        
        self.image.hidden = true
        
    }
    
    func loadProgress() {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
    }
    
    func updateImage(email:String, increment:String) {
        
        loadProgress()
        
        var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
        var select_image = info["SelectImageUrl"] as! String
        
        Alamofire.request(.GET, "http://" + select_image, parameters: ["email": email, "increment": increment])
            .responseJSON { (req, res, json, error) in
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                if(error != nil) {
                    
                    self.displayAlert("Error in the form", message: "Something went wrong")
                    
                }
                    
                else {
                    
                    var json:JSON = JSON(json!)

                    if json["info"] == "You have not uploaded and images." {
                        
                        // add label here
                        
                    } else {
                        let data_url = json["s3_url"].stringValue
                        let word_label = json["word"].stringValue
                        
                        if let url = NSURL(string: data_url) {
                            
                            if let data = NSData(contentsOfURL: url) {
                                
                                let gesture = UIPanGestureRecognizer(target: self, action: "wasDragged:")
                                self.cardView.addGestureRecognizer(gesture)
                                self.cardView.userInteractionEnabled = true
                                self.cardView.contentMode = UIViewContentMode.ScaleAspectFill
                                self.image.image = UIImage(data: data)
                                self.image.hidden = false
                                self.tapRec.addTarget(self, action: "showWord")
                                self.tapLabel.addGestureRecognizer(self.tapRec)
                                self.tapLabel.userInteractionEnabled = true
                                self.wordLabel.textColor = UIColor.clearColor()
                                self.wordLabel.text = word_label
                                
                            }
                            
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
    
}
