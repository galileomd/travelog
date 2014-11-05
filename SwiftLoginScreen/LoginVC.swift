//
//  LoginVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class LoginVC: UIViewController,UITextFieldDelegate {
    
	
	var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		spinner.hidden = true
		spinner.stopAnimating()
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(animated: Bool)
	{		
		if let username = prefs.stringForKey("USERNAME")
		{
			println("Found username")
			txtUsername.text = username
		}
		
	}
	
	override func viewDidDisappear(animated: Bool) {
		spinner.hidden = true
		spinner.stopAnimating()
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
	
	@IBAction func starSpinner(sender: AnyObject) {
		spinner.hidden = false
		spinner.startAnimating()
	}
	
	func stopSpinner() {
		spinner.hidden = true
		spinner.stopAnimating()
	}
	
    @IBAction func signinTapped(sender : UIButton) {
        var username = txtUsername.text
        var password = txtPassword.text
		var url = "http://log.galileomd.com/api/loginjson.php"
        
        if ( (username == "") || (password == "") ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
			alertView.show()
        } else {
            
            var post:NSString = "username=\(username)&password=\(password)"
            
            NSLog("PostData: %@",post);
			
			var json = JsonController()
			var jsonResults = json.postData(url, postString: post)
			let success = jsonResults.objectAtIndex(0).valueForKey("success").integerValue
			
			NSLog("Success: \(success)");
                
            if(success == 1)
            {
                NSLog("Login SUCCESS");
				
				let userid = jsonResults.objectAtIndex(0).valueForKey("userid") as NSString
                prefs.setObject(userid, forKey: "USERID")
                prefs.setInteger(1, forKey: "ISLOGGEDIN")
                prefs.synchronize()
                    
				self.dismissViewControllerAnimated(true, completion: nil)				
            } else {
                var error_msg:NSString
                    
                if (jsonResults.valueForKey("error_message") != nil) {
                    error_msg = jsonResults.objectAtIndex(0).valueForKey("error_message") as NSString
                } else {
                    error_msg = "Unknown Error"
                }
            
				var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = error_msg
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
		}
		stopSpinner()
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
