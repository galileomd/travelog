//
//  billables.swift
//  Therapy Travel Log
//
//  Created by Sam Wang on 10/15/14.
//  Copyright (c) 2014 GalileoMD. All rights reserved.
//

import UIKit
import Foundation

class BillablesVC: UITableViewController {
	
	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	let activityIndicator = ViewControllerUtils()
	var billableid = ""

	
	@IBOutlet var tableViewy: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper billable.jpg"))
		//self.tabBarController?.tabBar[0].selectedImage = UIImage(imageNamed:"patient icon.png")
	}
	
	override func viewDidAppear(animated: Bool)
	{
		activityIndicator.showActivityIndicator(self.view)
		dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
			self.activityIndicator.hideActivityIndicator(self.view)
			self.loadBillableListFromJson()
			self.tableView.reloadData()
		})
	}
	
	@IBAction func logout(sender: AnyObject) {
		let appDomain = NSBundle.mainBundle().bundleIdentifier
		NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
		
		self.performSegueWithIdentifier("goto_login_frombillables", sender: self)
	}
	
	func loadBillableListFromJson()
	{
		// check that userID has been embedded in prefs from previous login
		if let id = prefs.stringForKey("USERID")
		{
			let url = "http://log.galileomd.com/api/billablesjson.php"
			let post = "userid=" + id
			let json = JsonController()
			let jsonResults = json.postData(url, postString: post)
			listTableItems.removeAllObjects()
			
			for dataDict : AnyObject in jsonResults {
				let billableDescription = dataDict.objectForKey("billableDescription") as NSString
				let billableId = dataDict.objectForKey("billableid") as NSString
				let billableStartTime = dataDict.objectForKey("billableStartTime") as NSString

				let dictionary = ["billableid":billableId, "billableDescription":billableDescription, "billableStartTime":billableStartTime]
				
				listTableItems.addObject(dictionary)
				println("Event \(billableDescription) loaded into global var listTableItems")
			}
		}
	}
	
	func showActivityIndicatory(uiView: UIView) {
		var container: UIView = UIView()
		container.frame = uiView.frame
		container.center = uiView.center
		
		var loadingView: UIView = UIView()
		loadingView.frame = CGRectMake(0, 0, 80, 80)
		loadingView.center = uiView.center
		loadingView.backgroundColor = UIColor.blueColor() //UIColorFromHex(0x444444, alpha: 0.7)
		loadingView.clipsToBounds = true
		loadingView.layer.cornerRadius = 10
		
		var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
		actInd.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
		actInd.activityIndicatorViewStyle =	UIActivityIndicatorViewStyle.WhiteLarge
		actInd.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 3);
		loadingView.addSubview(actInd)
		container.addSubview(loadingView)
		uiView.addSubview(container)
		actInd.startAnimating()
	}
	
	////////////// Table /////////////
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return listTableItems.count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
		
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
		
		//// get billable description from global variable listTableItems
		var tmpDict: NSDictionary = listTableItems[indexPath.row] as NSDictionary
		let cellTextDesc = tmpDict["billableDescription"] as? String
		let cellTextTime = tmpDict["billableStartTime"] as? String
		cell.textLabel?.text =   cellTextDesc! + " on " + cellTextTime!
		cell.backgroundColor = UIColor.clearColor()
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		println("You selected cell #\(indexPath.row)!")
		
		let tmpDict = listTableItems[indexPath.row] as NSDictionary
		billableid = tmpDict["billableid"] as String
		
		let billablePage = self.storyboard?.instantiateViewControllerWithIdentifier("viewBillableVC") as viewBillableVC
		billablePage.billableid = billableid
		self.navigationController?.pushViewController(billablePage, animated: true)

	}
	
	
	// ************ Cell delete function ***********
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		if (editingStyle == UITableViewCellEditingStyle.Delete) {
			/*
			tableView.beginUpdates()
			listTableItems.removeObjectAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			tableView.endUpdates()
			*/
			
			activityIndicator.showActivityIndicator(self.view)
			dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
				
				self.deleteJson(indexPath.row)
				self.loadBillableListFromJson()
				self.tableView.reloadData()
				
				self.activityIndicator.hideActivityIndicator(self.view)
			})
		}
	}
	
	func deleteJson(row: Int)
	{
		let tmpDict: NSDictionary = listTableItems[row] as NSDictionary
		let billableid = tmpDict["billableid"] as String
		
		var url = "http://log.galileomd.com/api/deactivatebillablejson.php"
		var post = "billableid=\(billableid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		println("Deleted \(billableid)")
	}
	// **********************************
	
}
