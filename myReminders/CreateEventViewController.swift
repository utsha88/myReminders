//
//  CreateEventViewController.swift
//  myReminders
//
//  Created by Utsha Guha on 8/11/16.
//  Copyright © 2016 Utsha Guha. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class CreateEventViewController: UIViewController,UITextFieldDelegate {
    var selYear:NSString?
    var selMonth:NSString?
    var selDate:NSString?
    var dateFromString:NSDate?
    var enteredData:NSString?

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var eventNote: UITextView!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventReminder: UITextField!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    @IBOutlet weak var duration: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        var dateString:NSString?
        dateString = "\(self.selDate!)-\(self.selMonth!.substringToIndex(3))-\(self.selYear!)"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        self.dateFromString = dateFormatter .dateFromString(dateString as! String)
        self.datePickerOutlet.date = self.dateFromString!;
        self.duration.text = "0.5"
        self.duration.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue .identifier == "segue_second"{
            let store = EKEventStore()
            store.requestAccessToEntityType(.Event, completion: {(granted, error) in
                if !granted {
                    return
                }
                
                //let eventDuration:Int?
               // eventDuration = Int(self.duration.text!)!*60
                let event = EKEvent (eventStore: store)
                event.calendar = store.defaultCalendarForNewEvents
                //event.startDate = self.dateFromString!
                event.startDate = self.datePickerOutlet.date
                event.endDate = self.datePickerOutlet.date.dateByAddingTimeInterval(Double(self.duration.text!)!*3600.0)
                event.title = self.eventName.text!
                event.location = self.eventLocation.text
                event.notes = self.eventNote.text
                
                if !(self.eventReminder.text?.isEmpty)!{
                    let aInterval:NSTimeInterval?
                    aInterval = 0 - Double(self.eventReminder.text!)!*60
                    let alarm:EKAlarm = EKAlarm(relativeOffset: aInterval!)
                    event.alarms = [alarm]
                }
                
                do {
                    try store.saveEvent(event, span: .ThisEvent, commit: true)
                } catch let err as NSError {
                    //error: Calendar is read only
                    print("error=\(err)")
                }
            })
            
            let vc:ViewController = segue.destinationViewController as! ViewController
        }
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
                return string == filtered
            }
            else{
                return false
            }
        }
        else if textField.tag == 200 {
            guard let text = textField.text else { return true }
            
            let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            let filtered:NSString = components.joinWithSeparator("")
            
            let newLength = text.characters.count + string.characters.count - range.length
            if newLength <= 2 {
                
                let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
                
                if string == filtered {
                    if !text.isEmpty{
                        self.createButton.enabled = true
                    } else {
                        self.createButton.enabled = false
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