//
//  TherapiesVC.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/12/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class TherapiesVC: UITableViewController
{
	var patientid = ""
	var patientname = ""
	let activityIndicator = ViewControllerUtils()
	let listTableItems: NSMutableArray = []
	let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
	
	@IBOutlet var anothertableData: UITableView!
	//@IBOutlet var spinner: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		println("Pushed variable \(patientid) to all therapies controller")
		self.refreshControl = UIRefreshControl()
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "wallpaper.jpg"))
		self.tableView.clearsContextBeforeDrawing = true
		
		//initialize spinner
		/*spinner.center = self.view.center
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
		spinner.hidesWhenStopped = true
		view.addSubview(spinner)
		spinner.startAnimating()
		*/
	}
	
	override func viewDidAppear(animated: Bool)
	{
		//spinner.startAnimating()
		activityIndicator.showActivityIndicator(self.view)
		dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
			self.refresh(self.refreshControl!)
			self.activityIndicator.hideActivityIndicator(self.view)
			//self.spinner.stopAnimating()
		})
	}
	
	func refresh(refreshController:UIRefreshControl)
	{
		navigationItem.title = "Therapies for " + patientname
		var formatter = NSDateFormatter()
		formatter.dateFormat = "MMM dd HH:mm"
		var title = "Updated " + formatter.stringFromDate(NSDate())
		
		refreshControl?.attributedTitle = NSAttributedString(string: title)
		refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		
		println("** View reloaded **")
		refreshController.endRefreshing()
		
		loadTherapiesListFromJson()
		self.tableView.reloadData()
		//spinner.stopAnimating()
		
	}
	
	
	func loadTherapiesListFromJson()
	{
		var url = "http://log.galileomd.com/api/therapieslistjson.php"
		var post = "patientid=\(patientid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		listTableItems.removeAllObjects()
		
		for dataDict : AnyObject in jsonResults {
			var therapyid = dataDict.objectForKey("therapyid") as NSString
			var therapy = dataDict.objectForKey("therapy") as NSString
			var visitCancelled = dataDict.objectForKey("visitCancelled") as NSString
			let dictionary = ["therapyid":therapyid, "therapy":therapy, "visitCancelled": visitCancelled]
			
			listTableItems.addObject(dictionary)
			println("Therapy \(therapy) loaded into global var listTableItems")
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
	
	////////  Table //////////
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return listTableItems.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		
		//// get list of therapies from global variable listTableItems
		var tmpDict: NSDictionary = listTableItems[indexPath.row] as NSDictionary
		
		cell.textLabel?.text = tmpDict["therapy"] as? String
		
		// if visit was cancelled label it as such in table view
		cell.backgroundColor = UIColor.clearColor()
		if (tmpDict["visitCancelled"] as String == "1" )
		{
			cell.textLabel?.text = cell.textLabel!.text! + " (cancelled)"
			cell.textLabel?.textColor = UIColor.lightGrayColor()
			cell.selectionStyle = UITableViewCellSelectionStyle.None
		} else
		{
			cell.textLabel?.textColor = UIColor.blackColor()
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		println("You selected cell #\(indexPath.row)!")
		
		let tmpDict = listTableItems[indexPath.row] as NSDictionary
		
		let toolsPage = self.storyboard?.instantiateViewControllerWithIdentifier("viewTherapyVC") as viewTherapyVC
		toolsPage.patientid = patientid
		toolsPage.therapyid = tmpDict["therapyid"] as String
		
		// allow segue to occur to details page only if visit was not cancelled
		if (tmpDict["visitCancelled"] as String != "1")
		{
			self.navigationController?.pushViewController(toolsPage, animated: true)
		}
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
				self.refresh(self.refreshControl!)
				
				self.activityIndicator.hideActivityIndicator(self.view)
			})
		}
	}
	
	func deleteJson(row: Int)
	{
		let tmpDict: NSDictionary = listTableItems[row] as NSDictionary
		let therapyid = tmpDict["therapyid"] as String
			
		var url = "http://log.galileomd.com/api/deactivatetherapyjson.php"
		var post = "therapyid=\(therapyid)&patientid=\(patientid)&userid=" + prefs.stringForKey("USERID")!
		var json = JsonController()
		var jsonResults = json.postData(url, postString: post)
		println("Deleted \(therapyid)")
	}
	// **********************************
	
	override func tableView(tableView:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat {
		return 44
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?)
	{
		if segue?.identifier == "goto_addtherapy"
		{
			let vc = segue?.destinationViewController as addTherapyVC
			vc.patientid = patientid
			vc.patientname = patientname
		}
	}
}
