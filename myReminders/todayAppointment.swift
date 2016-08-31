//
//  TodayAppointment.swift
//  myReminders
//
//  Created by Utsha Guha on 8/12/16.
//  Copyright © 2016 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import MessageUI

class TodayAppointment: UIViewController, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    var selYear:NSString?
    var selMonth:NSString?
    
    var selDate:NSString?
    var upcomingEventArray = NSMutableArray()
    @IBOutlet weak var numberOfDaysField: UITextField!
    @IBOutlet var eventTableView: UITableView!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberOfDaysField.text = "30"
        self.reloadButton.enabled = true
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.upcomingEventArray.count == 0 {
            return 1
        }
        else{
            return self.upcomingEventArray.count
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath)

        if self.upcomingEventArray.count == 0 {
            cell.textLabel?.text = "No Upcoming Event Found"
            cell.textLabel?.textColor = UIColor.redColor()
        }
        else{
            cell.textLabel?.text = self.upcomingEventArray[indexPath.item] as? String
            cell.textLabel?.textColor = UIColor.yellowColor()
      }
        cell.textLabel?.font = UIFont .systemFontOfSize(10)
        return cell
    }
    
    @IBAction func sendEmail(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            
            let array = self.upcomingEventArray as NSArray as! [String]
            let joined = array.joinWithSeparator(",\n\n")
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            let numdays:AnyObject = self.numberOfDaysField.text!
            mail.setMessageBody("<p>Hello,</p><p><h3 style=\"color: #2e6c80;\">My Upcoming Events for next \(numdays) day(s) are listed below:</h2></p><p>\(joined)</p>", isHTML: true)
            mail.setSubject("My upcoming Events!")
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        let store = EKEventStore()
        store.requestAccessToEntityType(.Event, completion: {(granted, error) in
            if !granted {
                return
            }
            
            //let stringNumber = String(self.numberOfDaysField.text)
            //let numberFromString = Double(stringNumber)
            let numberFromString = 24*3600*Double(self.numberOfDaysField.text!)!
            let endDate = NSDate(timeIntervalSinceNow: numberFromString);
            let predicate = store.predicateForEventsWithStartDate(NSDate(), endDate: endDate, calendars: nil)
            self.upcomingEventArray.removeAllObjects()
            let eV = store.eventsMatchingPredicate(predicate) as [EKEvent]!
            for i in eV {
                let str1 = i.title
                let str2 = " is on "
                let str3 = (String(i.startDate) as NSString).substringToIndex(10)
                let obj = str1 + str2 + str3
                self.upcomingEventArray .addObject(obj)
            }
            dispatch_async(dispatch_get_main_queue(),{
                self.eventTableView .reloadData()
            });
            //self.eventTableView .reloadData()
        })
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let vc:ViewController = segue.destinationViewController as! ViewController
        }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                                                 replacementString string: String) -> Bool {
        if textField.tag == 100 {
            guard let text = textField.text else { return true }
                        
            let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            let filtered:NSString = components.joinWithSeparator("")
            
            let newLength = text.characters.count + string.characters.count - range.length
            if newLength <= 3 {
                let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
                
                if string == filtered {
                    if !text.isEmpty{
                        self.reloadButton.enabled = true
                    } else {
                        self.reloadButton.enabled = false
                    }
                }
                return string == filtered
            }
            else{
                return false
            }
        }
        return true
    }
    
    }