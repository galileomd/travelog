//
//  ToolsVC.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/11/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class addTherapyVC: UIViewController, UITextFieldDelegate	//, UIPickerViewDelegate, UIPickerViewDataSource
{
	var patientid = ""
	var patientname = ""
	var totalMiles = 0
	var startTime = NSDate()
	var endTime = NSDate()
	var units = 0.0
	//let travelTimeArray = ["10 mins","20 mins","30 mins","40 mins","50 mins", "1 hour", "1 hr 10 mins", "1 hr 20 mins", "1 hr 30 mins", "1 hr 40 mins", "1 hr 50 mins", "2 hrs"]

	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	let activityIndicator = ViewControllerUtils()
	
	@IBOutlet var labelNow: UILabel!
	@IBOutlet var inputOdometerStart: UITextField!
	@IBOutlet var inputOdometerEnd: UITextField!
	@IBOutlet var inputMilesTraveled: UITextField!
	@IBOutlet var inputTravelTime: UITextField!
	@IBOutlet var inputTherapyStarttime: UITextField!
	@IBOutlet var inputTherapyEndtime: UITextField!
	@IBOutlet var inputNumberUnits: UITextField!
	@IBOutlet var inputUnitType: UITextField!
	@IBOutlet var inputOptionalUnitBreakdown: UITextField!
	@IBOutlet var picker: UIPickerView! = UIPickerView()
	@IBOutlet var spinner: UIActivityIndicatorView!
	@IBOutlet weak var visitCancelled: UISwitch!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		////// Initializing the view //////
		stopSpinner()
		changeLabelTodaysDate()
		//pickerInit()
		
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg"))
		println("Pushed variable \(patientid) to new therapy controller")
	}
	
	func pickerInit()
	{
		//picker.delegate = self
		//picker.dataSource = self
		self.inputTravelTime.inputView = picker
	}
	
	@IBAction func cancelVisit(sender: AnyObject) {
		if (visitCancelled.on)
		{
			inputOdometerStart.enabled = false
			inputOdometerEnd.enabled = false
			inputMilesTraveled.enabled = false
			inputTravelTime.enabled = false
			inputOdometerStart.backgroundColor = UIColor.lightGrayColor()
			inputOdometerEnd.backgroundColor = UIColor.lightGrayColor()
			inputMilesTraveled.backgroundColor = UIColor.lightGrayColor()
			inputTravelTime.backgroundColor = UIColor.lightGrayColor()
			
			inputNumberUnits.enabled = false
			inputOptionalUnitBreakdown.enabled = false
			inputUnitType.enabled = false
			inputNumberUnits.backgroundColor = UIColor.lightGrayColor()
			inputOptionalUnitBreakdown.backgroundColor = UIColor.lightGrayColor()
			inputUnitType.backgroundColor = UIColor.lightGrayColor()
		
			inputTherapyStarttime.enabled = false
			inputTherapyEndtime.enabled = false
			inputTherapyStarttime.backgroundColor = UIColor.lightGrayColor()
			inputTherapyEndtime.backgroundColor = UIColor.lightGrayColor()
		}
		else
		{
			inputOdometerStart.enabled = true
			inputOdometerEnd.enabled = true
			inputMilesTraveled.enabled = true
			inputTravelTime.enabled = true
			inputOdometerStart.backgroundColor = UIColor.clearColor()
			inputOdometerEnd.backgroundColor = UIColor.clearColor()
			inputMilesTraveled.backgroundColor = UIColor.clearColor()
			inputTravelTime.backgroundColor = UIColor.clearColor()
			
			inputNumberUnits.enabled = true
			inputOptionalUnitBreakdown.enabled = true
			inputUnitType.enabled = true
			inputNumberUnits.backgroundColor = UIColor.clearColor()
			inputOptionalUnitBreakdown.backgroundColor = UIColor.clearColor()
			inputUnitType.backgroundColor = UIColor.clearColor()
			
			inputTherapyStarttime.enabled = true
			inputTherapyEndtime.enabled = true
			inputTherapyStarttime.backgroundColor = UIColor.clearColor()
			inputTherapyEndtime.backgroundColor = UIColor.clearColor()
		}
	}
	
	@IBAction func startDatePicker(sender: UITextField) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputTherapyStarttime.text = dateFormatter.stringFromDate(startTime)
		changeLabelTodaysDate()
		
		var datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleStartDatePicker:"), forControlEvents: UIControlEvents.AllEvents)
		
	}
	
	func handleStartDatePicker(sender: UIDatePicker) {
		startTime = sender.date
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputTherapyStarttime.text = dateFormatter.stringFromDate(startTime)
		changeLabelTodaysDate()
		println("\(endTime) - \(startTime)")
		calculateUnits()
	}
	
	@IBAction func endDatePicker(sender: UITextField) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputTherapyEndtime.text = dateFormatter.stringFromDate(endTime)
		
		var datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleEndDatePicker:"), forControlEvents: UIControlEvents.AllEvents)
		
	}
	
	func handleEndDatePicker(sender: UIDatePicker) {
		endTime = sender.date
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/dd - h:mm a"
		inputTherapyEndtime.text = dateFormatter.stringFromDate(endTime)
		println("\(endTime) - \(startTime)")
		calculateUnits()
	}
	
	@IBAction func starSpinner(sender: AnyObject) {
		spinner.hidden = false
		spinner.startAnimating()
	}
	
	func stopSpinner()
	{
		spinner.hidden = true
		spinner.stopAnimating()
	}
	
	@IBAction func saveResults(sender: AnyObject) {
		calculateTotalMiles()
		activityIndicator.showActivityIndicator(self.view)
		if ( (totalMiles != 0 && inputNumberUnits.text != "") || visitCancelled.on == true)
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
			alertView.message = "Need total miles and number of units"
			//alertView.delegate = self
			alertView.addButtonWithTitle("OK")
			alertView.show()
		}
		
		stopSpinner()
	}
	
	@IBAction func editChanged(sender: AnyObject) {
		calculateTotalMiles()
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
			let timeIntervalInMinutes = endTime.timeIntervalSinceDate(startTime) / 60
			units = floor(timeIntervalInMinutes / 15)
			let remainderMinutes = timeIntervalInMinutes % 15
			
			if (remainderMinutes >= 8)
			{
				units += 1
			}
			
			if units < 0
			{
				units = 0
			}
			inputNumberUnits.text = NSString(format: "%.0f", units)
			
			println("Minutes provided: \(timeIntervalInMinutes)")
			println("Units calculated: \(units)")
			
		}
	}
	
	func changeLabelTodaysDate()
	{
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		labelNow.text = formatter.stringFromDate(startTime)
	}
	
	///////////////// UIViewPicker  //////////////////
	// returns the number of 'columns' to display.
	/*****************
	func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int{
		return 1
	}
	
	// returns the # of rows in each component..
	func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
		return travelTimeArray.count
	}
	
	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		return travelTimeArray[row]
	}
	
	func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
	{
		inputTravelTime.text = "\(travelTimeArray[row])"
	}
	******************/
	
	//////////// Makes keyboard go away when off-touched ////////
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
	{
		self.view.endEditing(true)
	}
	
	//INSERT INTO OTTherapies (userid, patientid, inputOdometerStart, inputOdometerEnd, inputTotalMiles, inputTravelTime, inputTherapyStartime, inputTherapyEndtime, inputNumberUnits, inputUnitType, inputOptionalUnitBreakdown) VALUES ('sd', '1', NULL, NULL, '76', NULL, '8/14/14 22:38', '8/14/14 23:39', '4', NULL, NULL)

	func saveToJson()
	{
		var dateFormatter = NSDateFormatter()
		
		let userid = prefs.stringForKey("USERID")!
		let todaysDate = labelNow.text
		let OdometerStart = self.inputOdometerStart.text
		let OdometerEnd = self.inputOdometerEnd.text
		let TotalMiles = self.inputMilesTraveled.text
		let TravelTime = self.inputTravelTime.text
		let NumberUnits = self.inputNumberUnits.text
		let UnitType = self.inputUnitType.text
		let OptionalUnitBreakdown = self.inputOptionalUnitBreakdown.text
		
		var isVisitCancelled = 0
		if self.visitCancelled.on
		{
			isVisitCancelled = 1
		}
		
		//fix dates for submission
		dateFormatter.dateFormat = "yy/MM/dd HH:mm"
		var TherapyStartime	= dateFormatter.stringFromDate(startTime)
		var TherapyEndtime = dateFormatter.stringFromDate(endTime)
		
		var post = "userid=\(userid)&patientid=\(self.patientid)&OdometerStart=\(OdometerStart)&OdometerEnd=\(OdometerEnd)&TotalMiles=\(TotalMiles)&TravelTime=\(TravelTime)&TherapyStartTime=\(TherapyStartime)&TherapyEndTime=\(TherapyEndtime)&NumberUnits=\(NumberUnits)&UnitType=\(UnitType)&OptionalUnitBreakdown=\(OptionalUnitBreakdown)&visitCancelled=\(isVisitCancelled)"
		
		var url = "http://log.galileomd.com/api/addtherapyjson.php"
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		
		for dataDict : AnyObject in jsonResults {
			var success = dataDict.objectForKey("success") as NSInteger
			
			if success == 1
			{
				println("Successfully added therapy to patient list")
				self.navigationController?.popViewControllerAnimated(true)
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		//let index = tableView.indexPathForSelectedRow()
		//pizza.pizzaType = pizza.typeList[index.row]
		
		if segue.identifier == "mileageVC" {
			let vc = segue.destinationViewController as MileageVC
			vc.patientid = patientid
		}
	}
	
	//////// HACK to shift screen up to avoid keyboard overlay  //////////
	@IBAction func numberUnitsEditingDidBegin(sender: AnyObject) {
		self.view.frame.origin.y -= 120
	}
		
	@IBAction func unitsBreakdownEditingDidBegin(sender: AnyObject) {
		self.view.frame.origin.y -= 150
	}
	
	@IBAction func numberUnitsEditingDidEnd(sender: AnyObject) {
		self.view.frame.origin.y += 120
	}
	
	@IBAction func unitsBreakdownEditingDidEnd(sender: AnyObject) {
		self.view.frame.origin.y += 150
	}
}