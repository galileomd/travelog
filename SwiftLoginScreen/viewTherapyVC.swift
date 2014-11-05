//
//  viewTherapy.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/12/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class viewTherapyVC:UIViewController
{
	var patientid = ""
	var therapyid = ""
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	
	@IBOutlet var odometerStart: UILabel!
	@IBOutlet var odometerEnd: UILabel!
	@IBOutlet var totalMiles: UILabel!
	@IBOutlet var travelTime: UILabel!
	@IBOutlet var therapyStartTime: UILabel!
	@IBOutlet var therapyEndTime: UILabel!
	@IBOutlet var numberUnits: UILabel!
	@IBOutlet var unitType: UILabel!
	@IBOutlet var optionalUnitBreakdown: UILabel!
	@IBOutlet weak var patientName: UILabel!
	
	override func viewDidLoad()
	{
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg"))
		println("Pushed variable \(patientid) and \(therapyid) to view therapy controller")
		loadTherapyFromJson()
	}
	
	
	func loadTherapyFromJson()
	{
		var url = "http://log.galileomd.com/api/viewtherapyjson.php"
		var post = "therapyid=\(therapyid)&patientid=\(patientid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			patientName.text = dataDict.objectForKey("name") as NSString
			odometerStart.text = dataDict.objectForKey("odometerStart") as NSString
			odometerEnd.text = dataDict.objectForKey("odometerEnd") as NSString
			totalMiles.text = dataDict.objectForKey("totalMiles") as NSString
			travelTime.text = dataDict.objectForKey("travelTime") as NSString
			therapyStartTime.text = dataDict.objectForKey("therapyStartTime") as NSString
			therapyEndTime.text = dataDict.objectForKey("therapyEndTime") as NSString
			numberUnits.text = dataDict.objectForKey("numberUnits") as NSString
			unitType.text = dataDict.objectForKey("unitType") as NSString
			optionalUnitBreakdown.text = dataDict.objectForKey("optionalUnitBreakdown") as NSString
			
		}
	}
}
