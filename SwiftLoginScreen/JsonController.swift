//
//  JsonController.swift
//  SwiftLoginScreen
//
//  Created by Sam Wang on 8/9/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

import UIKit

class JsonController {
	
	func postData(urlString:NSString, postString:NSString) -> NSMutableArray
	{
		var url:NSURL = NSURL.URLWithString(urlString)
		var postData:NSData = postString.dataUsingEncoding(NSASCIIStringEncoding)!
		var postLength:NSString = String( postData.length )
		var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
		var jsonData:NSMutableArray = []
		
		request.HTTPMethod = "POST"
		request.HTTPBody = postData
		request.setValue(postLength, forHTTPHeaderField: "Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		
		
		var error: NSError?
		var response: NSURLResponse?
		var urlData:NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)!
		
		let res = response as NSHTTPURLResponse!;
		
		NSLog("Post --> %@", postString)
		NSLog("Response code: %ld", res.statusCode)
		
		if (res.statusCode >= 200 && res.statusCode < 300)
		{
			var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)
			
			NSLog("Response ==> %@", responseData);
			
			var error: NSError?
			
			let tmpJsonData = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSMutableArray
			
			jsonData = tmpJsonData
		} else if (res.statusCode == 404)
		{
			var alertView:UIAlertView = UIAlertView()
			alertView.title = "Submit failed!"
			alertView.message = "No URL \(url) found"
			//alertView.delegate = self
			alertView.addButtonWithTitle("OK")
			alertView.show()
		} else
		{
			var alertView:UIAlertView = UIAlertView()
			alertView.title = "Network Failed!"
			alertView.message = "Connection Failed"
			//alertView.delegate = self
			alertView.addButtonWithTitle("OK")
			alertView.show()
		}
		
		return jsonData
	}
}