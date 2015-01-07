//
//  SellingViewController.swift
//  garagrIOS
//
//  Created by Martin Gingras on 2014-12-14.
//  Copyright (c) 2014 mgingras. All rights reserved.
//

import UIKit



class SellingViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate
{
    var userId: NSNumber?
    var username: NSString?
    
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var uploadPlusBtn: UIButton!
    @IBOutlet weak var uploadTxtBtn: UIButton!
    @IBOutlet weak var itemAmount: UITextField!
    @IBOutlet weak var emptyFieldsLabel: UILabel!

    
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.userId = appDelegate.userId
        self.username = appDelegate.username
        
        itemDescription.layer.cornerRadius = 5
        itemDescription.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        itemDescription.layer.borderWidth = 0.5
        itemDescription.clipsToBounds = true
        itemImage.layer.cornerRadius = 5
        itemImage.layer.cornerRadius = 5
        itemImage.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        itemImage.layer.borderWidth = 0.5
    }
    
    @IBAction func uploadImage(){
        var alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openCamera()
                
        }
        var galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
            {
                UIAlertAction in
                self.openGallery()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                UIAlertAction in
                
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        picker?.delegate = self
        
        
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(uploadPlusBtn.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else{
            openGallery()
        }
    }
    func openGallery(){
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else{
            popover=UIPopoverController(contentViewController: picker!)
            popover!.presentPopoverFromRect(uploadPlusBtn.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)
    {
        println("picker controller")
        picker .dismissViewControllerAnimated(true, completion: nil)
        itemImage.image=(info[UIImagePickerControllerOriginalImage] as UIImage)
        uploadPlusBtn.hidden = true
        uploadTxtBtn.hidden = false
    }
    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
//    {
//        println("picker cancel")
//    }
    

    @IBAction func uploadItem(){
        let name = self.itemName.text
        let description = self.itemDescription.text
        let amount = Double(round(100*(self.itemAmount.text as NSString).doubleValue) / 100)
        let image = self.itemImage.image
        var err: NSError?
        
        let isntComplete = name.isEmpty || description.isEmpty || amount <= 0 || image?.description == nil

        if(isntComplete){
            self.emptyFieldsLabel.hidden = false
            return
        }else{
            self.emptyFieldsLabel.hidden = true
        }
        
        var url = NSURL(string: "http://localhost:3000/products")
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var imageData = UIImagePNGRepresentation(image?)

        var base64String = imageData.base64EncodedStringWithOptions(nil) // encode the image

        var params = ["name": name, "description": description, "amount": amount, "image":[ "content_type": "image/jpeg", "filename":name + ".jpg", "file_data": base64String], "seller": self.userId!]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(0), error: &err)!
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            

            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            let status: String! = jsonResult["status"] as NSString
            if status != "ok" {
                let message: String! = jsonResult["message"] as NSString
                var alert:UIAlertController=UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock(){
                        self.performSegueWithIdentifier("sellingToLoggedInViewSegue", sender: self)
                    }
                }))
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let message: String! = jsonResult["message"] as NSString
                var alert:UIAlertController=UIAlertController(title: "Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock(){
                        self.performSegueWithIdentifier("sellingToLoggedInViewSegue", sender: self)
                    }
                }))
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        task.resume()

        
    }
    
}
