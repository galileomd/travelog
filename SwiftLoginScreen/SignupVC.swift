//
//  SignupVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {

    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtConfirmPassword : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    @IBAction func gotoLogin(sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signupTapped(sender : UIButton) {
        var username = txtUsername.text as NSString
        var password = txtPassword.text as NSString
        var confirm_password = txtConfirmPassword.text as NSString
        
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if ( !password.isEqual(confirm_password) ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Passwords don't match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            var post:NSString = "username=\(username)&password=\(password)&c_password=\(confirm_password)"
            
            NSLog("PostData: %@",post);
            
            var url = NSURL.URLWithString("http://log.galileomd.com/api/signupjson.php")
            var postData = post.dataUsingEncoding(NSASCIIStringEncoding)
            var postLength = String( postData!.length )
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
			
            var error: NSError?
            var response: NSURLResponse?
			
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
			
            var urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
            
            let res = response as NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)
                
                NSLog("Response ==> %@", responseData);
                
                var error: NSError?
                
                let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
                                
                let success = jsonData.valueForKey("success")?.integerValue
				
                NSLog("Success: %ld", success!);
                
                if(success == 1)
                {
					NSLog("Sign Up SUCCESS");
					var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
					prefs.setObject(username, forKey: "USERNAME")
					prefs.synchronize()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    var error_msg:NSString
                    
                    if jsonData["error_message"] as? NSString == 1 {
                        error_msg = jsonData["error_message"] as NSString
                    } else {
                        error_msg = "Unknown Error"
                    }
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = error_msg
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                    
                }
                
            } else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign Up Failed!"
                alertView.message = "Connection Failed"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
	
	
	// Makes keyboard go away when off-touched
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
	{
		self.view.endEditing(true)
	}	
}
