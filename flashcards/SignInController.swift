//
//  SignInController.swift
//  flashcards
//
//  Created by Eric Iacutone on 8/22/15.
//  Copyright (c) 2015 Iacutone. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class SignInController: UIViewController {

    @IBOutlet var signInButton: UIButton!
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var userPassword: UITextField!

    @IBOutlet var error: UILabel!
    
    @IBAction func signIn(sender: AnyObject) {
        
        var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
        let key = "p4ssw0rd"
        let encrypted_data = AESCrypt.encrypt(userPassword.text, password: key)
        
        var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
        var sign_in_url = info["SignInUrl"] as! String
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
        
        if email.text == "" || userPassword.text == "" {
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            displayAlert("Error in the form", message: "Please enter an email and a password.")
            
        } else {
            
            Alamofire.request(.POST, "http://" + sign_in_url, parameters: ["email": email.text, "password": encrypted_data])
                .responseJSON { (req, res, json, error) in
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    
                    var json = JSON(json!)
                    
                    if(json["success"] == false) {
                        
                        let message:String = json["info"].stringValue
                        self.displayAlert("There was a problem with sign in", message: message)
                        
                    }
                        
                    else {
                        
                        let id = json["id"].numberValue
                        let email = json["email"].stringValue

                        self.updateUserLoggedIn(email)
                        
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        
                        let imageIndexController:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("imageIndex") as! UIViewController
                        
                        self.presentViewController(imageIndexController, animated: true, completion: nil)
                        
                    }
                    
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signInButton.backgroundColor = UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0)
        signInButton.layer.cornerRadius = 5
        
    }
    
    func displayAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func updateUserLoggedIn(email:String) {
        // Update the NSUserDefaults
        
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setObject("loggedIn", forKey: "userLoggedIn")
        defaults.setObject(email, forKey: "Email")
        defaults.setObject(NSDate(), forKey: "LastRun")
        defaults.setObject(0, forKey: "count")
        defaults.synchronize()
    }

}
