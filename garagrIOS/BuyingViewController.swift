//
//  BuyingViewController.swift
//  garagrIOS
//
//  Created by Martin Gingras on 2014-12-14.
//  Copyright (c) 2014 mgingras. All rights reserved.
//

import UIKit

class BuyingViewController: UIViewController {
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    var sellerId: Int?

    var userId: NSNumber?
    var username: NSString?
    var ids:[Int]?
    var currentId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.userId = appDelegate.userId
        self.username = appDelegate.username
        
        if(self.ids?.count >= 0){
            self.loadNewProduct(self.currentId!)
            return
        }
        var url = NSURL(string: "http://localhost:3000/products")
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
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
                println("ERROR: " + message)
                
            }else{
                self.ids = jsonResult["ids"] as? Array
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.currentId = self.ids?.last as Int!
                    self.ids?.removeLast()
                    self.loadNewProduct(self.currentId!)
                }
                
            }
            
        }
        
        task.resume()
    }
 
    @IBAction func swipeRight(sender: AnyObject) {
        var alert = UIAlertController(title: "Make an offer for " + self.productName.text! + "?", message: "How much would you like to offer?", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = self.productPrice.text!
            textField.placeholder = "Amount"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){
            UIAlertAction in
        })
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            let amountToOffer = alert.textFields![0] as UITextField
            let amount = Double(round(100*(amountToOffer.text as NSString).doubleValue) / 100)
            self.makeOffer(amount)
            
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func swipeLeft(sender: AnyObject) {
        if(ids?.count == 0){
            var alert:UIAlertController=UIAlertController(title: "No products", message: "Sorry you have seen all the products, come back later to see more", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.performSegueWithIdentifier("buyingToLoggedInViewSegue", sender: self)
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        self.currentId = self.ids?.last as Int!
        self.ids?.removeLast()
        self.performSegueWithIdentifier("buyingShowSelf", sender: self)
    }
    
    func loadNewProduct(id: Int){
        var url = NSURL(string: "http://localhost:3000/products/" + String(id))
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){(data, response, error) in
            
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if (err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            let status: String! = jsonResult["status"] as NSString
            if status != "ok" {
                let message: String! = jsonResult["message"] as NSString
                println("ERROR: " + message)
                
            }else{
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.productName.text = jsonResult["productName"] as NSString
                    self.productDescription.text = jsonResult["productDescription"] as NSString
                    let price = jsonResult["price"] as Double
                    self.productPrice.text = String(format:"%.2f", price)
                    let imageString = jsonResult["image"] as String
                    let decodedData = NSData(base64EncodedString: imageString, options: nil)
                    var decodedimage = UIImage(data: decodedData!)
                    self.productImage.image = decodedimage
                    self.sellerId = jsonResult["productDescription"] as? Int
                    println(self.sellerId)
                }
                
            }
            
        }
        
        task.resume()
    }
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if segue.identifier == "buyingShowSelf" {
            var bVC = segue.destinationViewController as BuyingViewController
            bVC.productName = self.productName
            bVC.productDescription = self.productDescription
            bVC.productPrice = self.productPrice
            bVC.productImage = self.productImage
            bVC.ids = self.ids
            bVC.currentId = self.currentId
        }
    }
    
    func makeOffer(amount: Double){
        var url = NSURL(string: "http://localhost:3000/offers")
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        println(amount)
        println(self.userId!)
        println(self.currentId!)
        var params = ["amount": amount, "buyerId": self.userId!, "productId": self.currentId!]
        
        var err: NSError?
        
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
                        self.swipeLeft(self)
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
                        self.swipeLeft(self)
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
