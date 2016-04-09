//
//  DetailImageTableViewController.swift
//  flashcards
//
//  Created by Eric Iacutone on 9/20/15.
//  Copyright (c) 2015 Iacutone. All rights reserved.
//

import UIKit

class DetailImageTableViewController: UITableViewController {

    @IBOutlet var editImageTextField: UITextField!
    
    var index:Int?
    
    var imageArray:[String]!
    
    var editedImage:String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        editImageTextField.text = imageArray[index!]
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            editImageTextField.becomeFirstResponder()
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        editedImage = editImageTextField.text as String
        
    }

}
