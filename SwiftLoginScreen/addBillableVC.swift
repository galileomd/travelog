//
//  addBillable.swift
//  Therapy Travel Log
//
//  Created by Sam Wang on 10/16/14.
//  Copyright (c) 2014 GalileoMD. All rights reserved.
//

import Foundation
import UIKit

class addBillableVC:  UIViewController, UITextFieldDelegate
{
	var totalMiles = 0
	var startTime = NSDate()
	var endTime = NSDate()
	
	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	let activityIndicator = ViewControllerUtils()
	
	@IBOutlet var labelNow: UILabel!
	@IBOutlet var inputOdometerStart: UITextField!
	@IBOutlet var inputOdometerEnd: UITextField!
	@IBOutlet var inputMilesTraveled: UITextField!
	@IBOutlet var inputStarttime: UITextField!
	@IBOutlet var inputEndtime: UITextField!
	@IBOutlet var inputNumberUnits: UITextField!
	@IBOutlet var inputDescription: UITextField!
	@IBOutlet var spinner: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper billable.jpg"))
		
		////// Initializing the view //////
		stopSpinner()
		changeLabelTodaysDate()
		println("Pushed variable \(labelNow) to new therapy controller")
	}
	
	@IBAction func startDatePicker(sender: UITextField) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputStarttime.text = dateFormatter.stringFromDate(startTime)
		changeLabelTodaysDate()
		
		let datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleStartDatePicker:"), forControlEvents: UIControlEvents.AllEvents)
		
	}
	
	func handleStartDatePicker(sender: UIDatePicker) {
		startTime = sender.date
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputStarttime.text = dateFormatter.stringFromDate(startTime)
		changeLabelTodaysDate()
		println("\(endTime) - \(startTime)")
		calculateUnits()
	}
	
	@IBAction func endDatePicker(sender: UITextField) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputEndtime.text = dateFormatter.stringFromDate(endTime)
		
		let datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleEndDatePicker:"), forControlEvents: UIControlEvents.AllEvents)
		
	}
	
	func handleEndDatePicker(sender: UIDatePicker) {
		endTime = sender.date
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputEndtime.text = dateFormatter.stringFromDate(endTime)
		println("\(endTime) - \(startTime)")
		calculateUnits()
	}
	
	@IBAction func editChanged(sender: AnyObject) {
		calculateTotalMiles()
	}
	
	
	
	@IBAction func saveResults(sender: AnyObject) {
		calculateTotalMiles()
		activityIndicator.showActivityIndicator(self.view)
		if ( totalMiles != 0 && inputNumberUnits.text != "" && inputDescription.text != "")
		{
			dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
				self.saveToJson()
				self.activityIndicator.hideActivityIndicator(self.view)
			})
		}
		else
		{
			activityIndicator.hideActivityIndicator(self.view)
			var alertView:UIAlertView = UIAlertView()
			alertView.title = "Fields missing"
			alertView.message = "Need total miles, units, and a description"
			//alertView.delegate = self
			alertView.addButtonWithTitle("OK")
			alertView.show()
		}
		
		stopSpinner()
	}
	
	func stopSpinner()
	{
		spinner.hidden = true
		spinner.stopAnimating()
	}
	
	/////////////// Updates to Input fields ////////////////
	func calculateTotalMiles()
	{
		if ( inputOdometerStart.text != "" && inputOdometerEnd.text != "" )
		{
			totalMiles = inputOdometerEnd.text.toInt()! - inputOdometerStart.text.toInt()!
			if totalMiles < 0
			{
				totalMiles = 0
			}
			inputMilesTraveled.text = String(totalMiles)
		}
		
		if (inputMilesTraveled.text == "")
		{
			totalMiles = 0
		}
		else
		{
			totalMiles = inputMilesTraveled.text.toInt()!
		}
		
	}
	
	func calculateUnits()
	{
		if (endTime != "" && startTime != "")
		{
			let timeIntervalInHours = endTime.timeIntervalSinceDate(startTime) / 3600
			inputNumberUnits.text = NSString(format: "%.1f", timeIntervalInHours)
			
			println("Hours provided: \(timeIntervalInHours)")
			
		}
	}
	
	func changeLabelTodaysDate()
	{
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		labelNow.text = formatter.stringFromDate(startTime)
	}
	
	func saveToJson()
	{
		var dateFormatter = NSDateFormatter()
		
		let userid = prefs.stringForKey("USERID")!
		let todaysDate = labelNow.text
		let OdometerStart = self.inputOdometerStart.text
		let OdometerEnd = self.inputOdometerEnd.text
		let TotalMiles = self.inputMilesTraveled.text
		let NumberUnits = self.inputNumberUnits.text
		let billableDescription = self.inputDescription.text
		
		//fix dates for submission
		dateFormatter.dateFormat = "yy/MM/dd HH:mm"
		var billableStartime	= dateFormatter.stringFromDate(startTime)
		var billableEndtime = dateFormatter.stringFromDate(endTime)
		
		var post = "userid=\(userid)&OdometerStart=\(OdometerStart)&OdometerEnd=\(OdometerEnd)&TotalMiles=\(TotalMiles)&billableStarttime=\(billableStartime)&billableEndtime=\(billableEndtime)&billableDescription=\(billableDescription)"
		
		var url = "http://log.galileomd.com/api/addbillablejson.php"
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			var success = dataDict.objectForKey("success") as NSInteger
			
			if success == 1
			{
				println("Successfully added event to billable list")
				self.navigationController?.popViewControllerAnimated(true)
			}
		}
	}
	
	//////////// Makes keyboard go away when off-touched ////////
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
	{
		self.view.endEditing(true)
	}
	
	@IBAction func eventDescriptionEditingDidBegin(sender: AnyObject) {
		self.view.frame.origin.y -= 150
	}
	
	@IBAction func eventDescriptionEditingDidEnd(sender: AnyObject) {
		self.view.frame.origin.y += 150
	}
	
}