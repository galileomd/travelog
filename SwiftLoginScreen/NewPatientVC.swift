//
//  NewPatientVC.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/11/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class NewPatientVC:UIViewController
{
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	var dictionary:NSDictionary = [:]
	
	@IBOutlet var firstname: UITextField!
	@IBOutlet var lastname: UITextField!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	@IBAction func starSpinner(sender: AnyObject) {
		spinner.hidden = false
		spinner.startAnimating()
	}
	
	func stopSpinner() {
		spinner.hidden = true
		spinner.stopAnimating()
	}
	
	@IBAction func saveAndSegue(sender: AnyObject) {
		starSpinner(sender)
		var url = "http://log.galileomd.com/api/addPatientjson.php"
		var firstname = self.firstname.text
		var lastname = self.lastname.text
		
		var post = "firstname=\(firstname)&lastname=\(lastname)&userid=" + prefs.stringForKey("USERID")!
		
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			var success = dataDict.objectForKey("success") as Int
			var ptid = dataDict.objectForKey("patientid") as NSString
			var ptname = dataDict.objectForKey("patientname") as NSString
			dictionary = ["patientid":ptid, "patientname":ptname]
			println("Added new patient \(dictionary)")
		}
		
		/*
		let nextPage = self.storyboard.instantiateViewControllerWithIdentifier("TherapiesVC") as TherapiesVC
		nextPage.patientid = dictionary["patientid"] as String
		nextPage.patientname = dictionary["patientname"] as String
		self.navigationController.pushViewController(nextPage, animated: true)
		*/
		
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		stopSpinner()
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg"))
	}
	
	// Makes keyboard go away when off-touched
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
	{
		self.view.endEditing(true)
	}
	
	/*
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
	{
		
		let vc = segue.destinationViewController as TherapiesVC
		vc.patientid = "test"//dictionary["patientid"] as String
		vc.patientname = dictionary["patientname"] as String
	}

	
	*/
	
}
