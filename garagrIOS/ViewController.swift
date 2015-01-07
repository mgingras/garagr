//
//  ViewController.swift
//  garagrIOS
//
//  Created by Martin Gingras on 2014-12-01.
//  Copyright (c) 2014 mgingras. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var formUsername: UITextField!
    @IBOutlet weak var formPassword: UITextField!
    @IBOutlet weak var feedback: UILabel!
    var userId: NSNumber?
    var username: NSString?



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func validateUsernameAndPassword(){
        if formUsername.hasText() && formPassword.hasText() {
            getUserInfo(formUsername.text, formPassword: formPassword.text, handleFormInput)
        }
    }
    
    func handleFormInput(isValid: Bool){
        if(isValid){
            self.performSegueWithIdentifier("moveToUserViewSegue", sender: self)
        }
    }
    
    func getUserInfo(formUsername: String, formPassword: String, callback: (Bool)-> Void){
        let url = NSURL(string: "http://localhost:3000/login?username=" + formUsername + "&password=" + formPassword)
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            let status: String! = jsonResult["status"] as NSString
            if status != "ok" {
                let message: String! = jsonResult["message"] as NSString
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.feedback.text = message
                    callback(false)
                }
            } else{
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.userId = jsonResult["userId"] as? NSNumber
                    self.username = formUsername
                    callback(true)
                }
            }
        }
        task.resume()
    }
    
    @IBAction func showSignUpAlert(){
        showAlert("Enter details below")
    }
    func showAlert(message :NSString){
        var alert = UIAlertController(title: "Create new account", message: message, preferredStyle: .Alert)

        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Username"
        })
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){
            UIAlertAction in
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let desiredUsername = alert.textFields![0] as UITextField
            let desiredPassword = alert.textFields![1] as UITextField
            if !desiredPassword.hasText() || !desiredUsername.hasText() {
                self.showAlert("Please enter your desired Username and Password")
            }else{
                var url = NSURL(string: "http://localhost:3000/users?username=" + desiredUsername.text + "&password=" + desiredPassword.text)
                var request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request){(data, response, error) in
                    println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    
                    var err: NSError?
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                    if (err != nil) {
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    
                    let status: String! = jsonResult["status"] as NSString
                    if status != "ok" {
                        let message: String! = jsonResult["message"] as NSString
                        self.showAlert(message)
                    }else{
                        self.userId = jsonResult["userId"] as? NSNumber
                        NSOperationQueue.mainQueue().addOperationWithBlock(){
                            self.formUsername.text = desiredUsername.text
                        }
                    }
                    
                }
                
                task.resume()
            }
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier == "moveToUserViewSegue" {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.userId = self.userId
            appDelegate.username = self.username
        }
    }


}

