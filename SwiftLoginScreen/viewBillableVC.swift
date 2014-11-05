//
//  viewBillable.swift
//  Therapy Travel Log
//
//  Created by Sam Wang on 10/17/14.
//  Copyright (c) 2014 GalileoMD. All rights reserved.
//

import UIKit

class viewBillableVC: UIViewController
{
	var billableid = ""	
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	
	
	@IBOutlet var odometerStart: UILabel!
	@IBOutlet var odometerEnd: UILabel!
	@IBOutlet var totalMiles: UILabel!
	@IBOutlet var billableStartTime: UILabel!
	@IBOutlet var billableEndTime: UILabel!
	@IBOutlet var billableDescription: UILabel!
	
	override func viewDidLoad()
	{
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper billable.jpg"))
		println("Pushed variable \(billableid) to view therapy controller")
		loadTherapyFromJson()
	}
	
	
	func loadTherapyFromJson()
	{
		var url = "http://log.galileomd.com/api/viewbillablejson.php"
		var post = "billableid=\(billableid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			odometerStart.text = dataDict.objectForKey("odometerStart") as NSString
			odometerEnd.text = dataDict.objectForKey("odometerEnd") as NSString
			totalMiles.text = dataDict.objectForKey("totalMiles") as NSString
			billableStartTime.text = dataDict.objectForKey("billableStartTime") as NSString
			billableEndTime.text = dataDict.objectForKey("billableEndTime") as NSString
			billableDescription.text = dataDict.objectForKey("billableDescription") as NSString
			
		}
	}
}
