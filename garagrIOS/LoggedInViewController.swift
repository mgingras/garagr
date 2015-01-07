//
//  LoggedInViewController.swift
//  garagrIOS
//
//  Created by Martin Gingras on 2014-12-14.
//  Copyright (c) 2014 mgingras. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    
    var userId: NSNumber?
    var username: NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.userId = appDelegate.userId
        self.username = appDelegate.username
        self.usernameLabel.text = self.username
        
    }


    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier == "loggedInToSellingSegue" {
            var sVC = segue.destinationViewController as SellingViewController
            sVC.username = self.username
            sVC.userId = self.userId
        }
        if segue.identifier == "loggingOutSegue" {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.userId = -1
            appDelegate.username = ""
        }
    }
}
