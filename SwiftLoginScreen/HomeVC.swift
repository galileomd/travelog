//
//  HomeVC.swift
//  SwiftLoginScreen
//
//  Created by Dipin Krishna on 31/07/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit
import Foundation

class HomeVC: UITableViewController {
	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	let activityIndicator = ViewControllerUtils()
	
	//@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet var tableViewy: UITableView!
	
	@IBAction func logout(sender: AnyObject) {
		let appDomain = NSBundle.mainBundle().bundleIdentifier
		NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
		
		self.performSegueWithIdentifier("goto_login", sender: self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg"))
		self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		///////// pull-to-refresh is bound/instantiated
		self.refreshControl = UIRefreshControl()
		
		/////// authentication and redirection if not logged in
		let isLoggedIn = prefs.integerForKey("ISLOGGEDIN")
		if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
		}
		
		//// spinner init ////
		/*
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
		spinner.center = self.view.center
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		spinner.startAnimating()*/
	}
	
	override func viewDidAppear(animated: Bool)
	{
		activityIndicator.showActivityIndicator(self.view)
		dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
			self.refresh(self.refreshControl!)
			self.activityIndicator.hideActivityIndicator(self.view)
		})
	}
	
	////////// pull-to-refresh ///////////
	func refresh(refreshController:UIRefreshControl)
	{
		var formatter = NSDateFormatter()
		formatter.dateFormat = "MMM dd at HH:mm"
		var title = "Updated " + formatter.stringFromDate(NSDate())
		
		refreshControl?.attributedTitle = NSAttributedString(string: title)
		refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		
		///////  this needs to be before json load or pull-to-refresh doesnt tuck away
		println("REFRESHED")
		refreshController.endRefreshing()
		
		/////// reload table items from JSON ///////
		listTableItems.removeAllObjects()
		loadPatientListFromJson()
		self.tableView.reloadData()
		//spinner.stopAnimating()
	}
	
	func loadPatientListFromJson()
	{
		// check that userID has been embedded in prefs from previous login
		if let id = prefs.stringForKey("USERID")
		{
			let url = "http://log.galileomd.com/api/patientlistjson.php"
			var post = "userid=" + id
			let json = JsonController()
			let jsonResults = json.postData(url, postString: post)
		
			for dataDict : AnyObject in jsonResults {
				var pt = dataDict.objectForKey("patientname") as NSString
				var ptid = dataDict.objectForKey("patientid") as NSString
				let dictionary = ["patientname":pt, "patientid":ptid]
			
				listTableItems.addObject(dictionary)
				println("Patient \(pt) loaded into global var listTableItems")
			}
		}
	}
	
	////////////// Table /////////////
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return listTableItems.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
		
		//// get patient and id from global variable listTableItems
		var tmpDict: NSDictionary = listTableItems[indexPath.row] as NSDictionary
		cell.textLabel?.text = tmpDict["patientname"] as? String
		cell.backgroundColor = UIColor.clearColor()
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		println("You selected cell #\(indexPath.row)!")
		
		//// bind to next controller
		//// get the current patientID in selected row from global variable listTableItems
		//// forward variable to next controller and push view to next controller
		let toolsPage = self.storyboard?.instantiateViewControllerWithIdentifier("TherapiesVC") as TherapiesVC
		let tmpDict = listTableItems[indexPath.row] as NSDictionary
		toolsPage.patientid = tmpDict["patientid"] as String
		toolsPage.patientname = tmpDict["patientname"] as String

		self.navigationController?.pushViewController(toolsPage, animated: true)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
}
