//
//  ViewController.swift
//  ContactPicker
//
//  Created by Don Mag on 2/24/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

import UIKit

import Contacts
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate {

	
	@IBOutlet weak var resultsLabel: UILabel!
	
	@IBOutlet weak var resultsImageView: UIImageView!
	
	// initialize variables for saving contact
	var firstName: String   = ""
	var lastName: String    = ""
	var phone: String       = ""
	var email: String       = ""
	var userImage:UIImage?
	var contactID: String   = ""

	var selectedContact: CNContact?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.resetSelection()
		self.resultsImageView.image = self.userImage
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	func resetSelection() -> Void {
		
		self.selectedContact = nil
		
		self.firstName = ""
		self.lastName = ""
		self.phone = ""
		self.email = ""
		self.userImage = self.missingImage()
		self.contactID = ""
		
	}
	
	@IBAction func doChooseContact(sender: AnyObject) {

		AppDelegate.getAppDelegate().requesAccessToContacts{ (accessGranted) -> Void in
			if accessGranted {

				self.resetSelection()
				
				let contactPickerViewController = CNContactPickerViewController()
				
				contactPickerViewController.delegate = self
				
				self.presentViewController(contactPickerViewController, animated: true, completion: nil)
				
			}
		}
		
	}
	

	func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {

		picker.dismissViewControllerAnimated(true, completion: {

			self.selectedContact = contact
			
			self.firstName = contact.givenName
			self.lastName = contact.familyName
			self.contactID = contact.identifier
			
			if let imageData = contact.imageData {
				self.userImage = UIImage(data: imageData)
			}
			
			self.doSave()
			
		})

	}
	
	func doSave() -> Void {
		
		if self.phone == "" {
			
			// if any "get phone" option fails (such as contact has no phone number), this will prevent an infinite loop
			self.phone = "no phone"
			
			if self.selectedContact?.phoneNumbers.count > 1 {
				self.doSelectPhone()
				return
			} else {
				if let pn = self.selectedContact?.phoneNumbers.first {
					if let pnv = pn.value as? CNPhoneNumber {
						self.phone = pnv.stringValue
					}
				}
			}
		}
		
		if self.email == "" {
			
			// if any "get email" option fails (such as contact has no email), this will prevent an infinite loop
			self.email = "no email"
			
			if self.selectedContact?.emailAddresses.count > 1 {
				self.doSelectEmail()
				return
			} else {
				if let em = self.selectedContact?.emailAddresses.first {
					if  let emv = em.value as? String {
						self.email = emv
					}
				}
			}
		}
		
		var ls = ""
		ls += self.firstName + " " + self.lastName + "\n\n"
		ls += self.phone + "\n\n"
		ls += self.email + "\n\n"
		ls += self.contactID
		
		self.resultsLabel.text = ls

		self.resultsImageView.image = self.userImage
		
	}
	
	func doError() -> Void {
		
	}
	
	func doSelectPhone() -> Void {
		
		//we need the user to select which phone number we want them to use
		let selectPhoneAlert = UIAlertController(title: "Please choose...", message: "This contact has multiple phone numbers, which one did you want use?", preferredStyle: UIAlertControllerStyle.Alert)
		
		//Loop through all the phone numbers that we got back
		guard let phoneNumbers = self.selectedContact?.phoneNumbers else {
			doError()
			return
		}
		
		for number in phoneNumbers {
			//Each object in the phone numbers array has a value property that is a CNPhoneNumber object, Make sure we can get that
			if let theNumber = number.value as? CNPhoneNumber {
				//Get the label for the phone number
				let phoneNumberLabel = CNLabeledValue.localizedStringForLabel(number.label)

				//Create a title for the action for the UIAlertVC that we display to the user to pick phone numbers
				let actionTitle = phoneNumberLabel + " - " + theNumber.stringValue
				
				//Create the alert action
				let numberAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: { (theAction) -> Void in
					
					self.phone = theNumber.stringValue

					self.doSave()
					
				})
				//Add the action to the AlertController
				selectPhoneAlert.addAction(numberAction)
			}
		}
		//Add a cancel action
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (theAction) -> Void in
			//Cancel action completion
			print("User Cancelled")
		})
		//Add the cancel action
		selectPhoneAlert.addAction(cancelAction)
		//Present the ALert controller
		self.presentViewController(selectPhoneAlert, animated: true, completion: nil)

	}
	
	func doSelectEmail() -> Void {
		
		//we need the user to select which phone number we want them to use
		let selectEmailAlert = UIAlertController(title: "Please choose...", message: "This contact has multiple email addresses, which one did you want use?", preferredStyle: UIAlertControllerStyle.Alert)
		
		//Loop through all the phone numbers that we got back
		guard let emailAddresses = self.selectedContact?.emailAddresses else {
			doError()
			return
		}
		
		for addr in emailAddresses {
			if let theAddr = addr.value as? String {
				
				// get the label for the email address
				let emailLabel = CNLabeledValue.localizedStringForLabel(addr.label)

				//Create a title for the action for the UIAlertVC that we display to the user to pick emails
				let actionTitle = emailLabel + " - " + theAddr
				
				//Create the alert action
				let addrAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: { (theAction) -> Void in

					self.email = theAddr
					
					self.doSave()
					
				})
				
				//Add the action to the AlertController
				selectEmailAlert.addAction(addrAction)
			}
		}
		//Add a cancel action
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (theAction) -> Void in
			//Cancel action completion
			print("User Cancelled")
		})
		//Add the cancel action
		selectEmailAlert.addAction(cancelAction)
		//Present the ALert controller
		self.presentViewController(selectEmailAlert, animated: true, completion: nil)
		
	}
	
	func contactPickerDidCancel(picker: CNContactPickerViewController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func missingImage() -> UIImage {
		let v = UIView(frame: self.resultsImageView.bounds)
		
		let l = UILabel(frame: v.bounds)
		
		v.backgroundColor = UIColor.cyanColor()
		l.textAlignment = .Center
		l.text = "No Image"
		
		v.addSubview(l)
		
		UIGraphicsBeginImageContextWithOptions(v.bounds.size, v.opaque, 0);
		v.drawViewHierarchyInRect(v.bounds, afterScreenUpdates: true)
		let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		return snapshotImageFromMyView
	}
	
}

