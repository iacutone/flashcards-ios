//
//  PostImageViewController.swift
//  flashcards
//
//  Created by Eric Iacutone on 8/22/15.
//  Copyright (c) 2015 Iacutone. All rights reserved.
//

import UIKit
import MBProgressHUD

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var chooseImageButton: UIButton!
    
    @IBOutlet var insertViewHolder: UIView!
    
    @IBOutlet var insertButton: UIButton!
    
    @IBOutlet var takePhoto: UIButton!
    
    @IBOutlet var imageToPost: UIImageView!
    
    @IBOutlet var word: UITextField!
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            
            var image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.Camera
            image.allowsEditing = true
            self.presentViewController(image, animated: true, completion: nil)
            
        } else {
            
            displayAlert("No Camera", message: "A camera is necessary to perform this operation")
            
        }
        
    }
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
        
    }
    
    @IBAction func postImage(sender: AnyObject) {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Sending"
        
        if word.text == "" ||  imageToPost.image == nil {
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            displayAlert("Error", message: "Please select both a word and an image")
            
        } else {
            
            let imageData:NSData = UIImageJPEGRepresentation(imageToPost.image, 100)
            let wordString:String = word.text
            let defaults = NSUserDefaults.standardUserDefaults()
            
            var info:[NSObject:AnyObject] = NSBundle.mainBundle().infoDictionary!
            var image_data_url = info["ImageDataUrl"] as! String
            
            
            if let email = defaults.stringForKey("Email") {
                SRWebClient.POST("http://" + image_data_url)
                    .data(imageData, fieldName:"photo", data: ["email": email, "image_name": wordString])
                    .send({(response:AnyObject!, status:Int) -> Void in
                        
                        },failure:{(error:NSError!) -> Void in
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            
                            self.displayAlert("Photo not uploaded", message: "Please try again")
                    })
                
            }
            
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let imageIndexController:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("imageIndex") as! UIViewController
                self.presentViewController(imageIndexController, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        takePhoto.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        takePhoto.setTitle(String.fontAwesomeIconWithName(.Camera), forState: .Normal)
        
        chooseImageButton.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        chooseImageButton.setTitleColor(UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0), forState: .Normal)
        chooseImageButton.setTitle(String.fontAwesomeIconWithCode("fa-picture-o"), forState: .Normal)
        
        insertViewHolder.layer.borderWidth = 1
        insertViewHolder.layer.cornerRadius = 5
        insertViewHolder.layer.borderColor = UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0).CGColor
        
        insertButton.backgroundColor = UIColor(red:0.37, green:0.44, blue:0.50, alpha:1.0)
        insertButton.layer.cornerRadius = 5
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        self.word.delegate = self
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject("loggedOut", forKey: "userLoggedIn")
            defaults.synchronize()
            
        }
        
    }
    
    func displayAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let loggedIn:String! = defaults.stringForKey("userLoggedIn")
        let email:String! = defaults.stringForKey("Email")

        if loggedIn != "loggedIn" || email == nil || email == "" {
            
            segueToSignInController()
            
        }
        
    }
    
    func segueToSignInController() {

        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        let signInController:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("signInController") as! UIViewController
        
        self.presentViewController(signInController, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }

}
