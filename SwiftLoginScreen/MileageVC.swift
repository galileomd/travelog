//
//  MileageVC.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/9/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class MileageVC: UIViewController
{
	var patientid = ""
	var totalMiles = 0
	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		println("Pushed variable \(patientid) to mileage controller")
	}
	
	
	func addMilesToPatient()
	{
		var url = "http://log.galileomd.com/api/addMilesToPatientjson.php"
		var post = "totalmiles=\(totalMiles)&patientid=\(patientid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			var pt = dataDict.objectForKey("patient") as NSString
			var ptid = dataDict.objectForKey("patientid") as NSString
			let dictionary = ["patient":pt, "patientid":ptid]
			
			listTableItems.addObject(dictionary)
			println("Patient \(pt) loaded into global var listTableItems")
		}
	}
	
	func saveToJson()
	{
		
	}
}