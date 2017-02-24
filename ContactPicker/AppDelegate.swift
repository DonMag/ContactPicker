//
//  AppDelegate.swift
//  ContactPicker
//
//  Created by Don Mag on 2/24/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

import UIKit

import Contacts

extension UIApplication {
	class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(nav.visibleViewController)
		}
		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				return topViewController(selected)
			}
		}
		if let presented = base?.presentedViewController {
			return topViewController(presented)
		}
		return base
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var contactStore = CNContactStore()

	class func getAppDelegate() -> AppDelegate {
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}

	func showMessage(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		
		let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
		}
		
		alertController.addAction(dismissAction)
		
		if let topVC = UIApplication.topViewController() {
			topVC.presentViewController(alertController, animated: true, completion: nil)
		}
	}
	
	func requesAccessToContacts(completionHandler: (accessGranted: Bool) -> Void) {
		let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
		
		switch authorizationStatus {
		case .Authorized:
			completionHandler(accessGranted: true)
			
		case .Denied, .NotDetermined:
			self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
				if access {
					completionHandler(accessGranted: access)
				}
				else {
					if authorizationStatus == CNAuthorizationStatus.Denied {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							let title = "Be Friendly!"
							let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
							self.showMessage(title, message: message)
						})
					}
				}
			})
			
		default:
			completionHandler(accessGranted: false)
		}
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

