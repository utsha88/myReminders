//
//  ViewController.swift
//  myReminders
//
//  Created by Utsha Guha on 8/10/16.
//  Copyright © 2016 Utsha Guha. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    var currentYear:NSString?
    var currentMonth:NSString?
    var currentDay:NSString?
    var currentDate:NSString?
    var monthArray:[NSString]?
    var dayArray:[NSString]?
    var tempDate:NSDate?
    var eventArray = NSMutableArray()
    

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var currMonthLabel: UILabel!
    @IBOutlet weak var currYearLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func gotoNextMonth(sender: AnyObject) {
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Weekday]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: self.tempDate!)
        var tempMonth = components.month + 1
        var tempYear = components.year
        if tempMonth>12 {
            tempMonth = 1
            tempYear += 1
        }
        if tempMonth<1 {
            tempMonth = 12
            tempYear -= 1
        }
        components.year = tempYear
        components.month = tempMonth
        self.tempDate = NSCalendar.currentCalendar().dateFromComponents(components)
        self .createCalendarLayoutForDate(self.tempDate!)
        self.addButton.enabled = false
    }
    
    @IBAction func gotoPrevMonth(sender: AnyObject) {
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Weekday]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: self.tempDate!)
        var tempMonth = components.month - 1
        var tempYear = components.year
        if tempMonth>12 {
            tempMonth = 1
            tempYear += 1
        }
        if tempMonth<1 {
            tempMonth = 12
            tempYear -= 1
        }
        components.year = tempYear
        components.month = tempMonth
        self.tempDate = NSCalendar.currentCalendar().dateFromComponents(components)
        self .createCalendarLayoutForDate(self.tempDate!)
        self.addButton.enabled = false
    }
    
    func fetchEvents(){
            let store = EKEventStore()
            store.requestAccessToEntityType(.Event, completion: {(granted, error) in
                if !granted {
                    return
                }
                let endDate = NSDate(timeIntervalSinceNow: 24*3600*30);
                let predicate = store.predicateForEventsWithStartDate(NSDate(), endDate: endDate, calendars: nil)
    
                let eV = store.eventsMatchingPredicate(predicate) as [EKEvent]!
                for i in eV {
                    let str1 = i.title
                    let str2 = " is on "
                    let str3 = (String(i.startDate) as NSString).substringToIndex(10)
                    let obj = str1 + str2 + str3
                    self.eventArray .addObject(obj)
                }
            })
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.addButton.enabled = false
        self.tempDate = NSDate()
        self.monthArray = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        self.dayArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        self.createCalendarLayoutForDate(self.tempDate!)
        self.fetchEvents()
    }
        
    func createCalendarLayoutForDate(inputDate: NSDate){
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Weekday]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: self.tempDate!)
        
        let range = NSCalendar.currentCalendar().rangeOfUnit(.Day, inUnit: .Month, forDate: self.tempDate!)
        let numberOfDaysInMonth = range.length
        
        var dayCount = components.weekday
        
        for _ in (0...components.day).reverse(){
            if dayCount>0 {
                dayCount = dayCount - 1
            }
            else{
                dayCount = 7
            }
        }
        
        if dayCount == 7 {
            dayCount = 6
        }
        
        if dayCount == 0 {
            dayCount = 7
        }
        
        self.currentDay = String(self.dayArray![dayCount - 1])
        self.currentYear = String(components.year)
        self.currentMonth = String(self.monthArray![components.month - 1])
        
        var counter = 1
        
        if self.buttonView.subviews.count > 0 {
            self.buttonView.subviews.forEach({ $0.removeFromSuperview() })
        }
        let totalCol = self.dayArray!.count
        
        for rowCount in 0...6{
            for colCount in 0...totalCol-1{
                let dateButton = UIButton()

                
                let xPoint = CGFloat(colCount)*40.0
                let yPoint = 30.0 + CGFloat(rowCount)*40.0
                
                dateButton.frame = CGRectMake(xPoint, yPoint, 34.0, 34.0)
                dateButton.addTarget(self, action: #selector(ViewController.dateSelected(_:)), forControlEvents: .TouchUpInside)
                if rowCount == 0 && colCount<dayCount-1 {
                    dateButton.setTitle("", forState: .Normal)
                    dateButton.enabled = false
                }
                else{
                    if counter>numberOfDaysInMonth {
                        dateButton.setTitle("", forState: .Normal)
                        dateButton.enabled = false
                    }
                    else
                    {
                        dateButton.enabled = true
                        let currFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Weekday]
                        let currComp = NSCalendar.currentCalendar().components(currFlags, fromDate: NSDate())
                        dateButton.setTitleColor(UIColor.brownColor(), forState: .Normal)
                        if (currComp.day == counter) && (currComp.month == components.month) {
                            dateButton.setTitleColor(UIColor.redColor(), forState: .Normal)
                            dateButton.tag = 100
                        }
                        dateButton.setTitle(String(counter), forState: .Normal)
                        counter += 1
                    }
                }
                self.buttonView .addSubview(dateButton)
            }
        }
        self.currMonthLabel.text = self.currentMonth as? String
        self.currYearLabel.text = self.currentYear as? String
        
    }
    
    func dateSelected(sender: UIButton){
        for button in self.buttonView.subviews {
            let b:UIButton = button as! UIButton
            if (b.titleLabel?.textColor == UIColor.yellowColor()) && (sender != b) {
                if b.tag == 100 {
                    [b .setTitleColor(UIColor.redColor(), forState: .Normal)]
                }
                else{
                    [b .setTitleColor(UIColor.brownColor(), forState: .Normal)]
                }
            }

        }
        
        if sender.titleLabel?.textColor == UIColor.brownColor() || sender.titleLabel?.textColor == UIColor.redColor() {
            [sender .setTitleColor(UIColor.yellowColor(), forState: .Normal)]
            self.addButton.enabled = true
        }
        else{
            if sender.tag == 100 {
                 [sender .setTitleColor(UIColor.redColor(), forState: .Normal)]
            }
            else{
                [sender .setTitleColor(UIColor.brownColor(), forState: .Normal)]
            }
            self.addButton.enabled = false
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selButtonTitle:NSString?
        for button in self.buttonView.subviews {
            let b:UIButton = button as! UIButton
            if b.titleLabel?.textColor == UIColor.yellowColor(){
                selButtonTitle = b.titleLabel?.text
                break
            }
            
        }
        if segue .identifier == "segue_first"{
            let vc:CreateEventViewController = segue.destinationViewController as! CreateEventViewController
            vc.selDate = selButtonTitle
            vc.selMonth = self.currentMonth
            vc.selYear = self.currentYear
        }
        else{
                let appVC:TodayAppointment = segue.destinationViewController as! TodayAppointment
                appVC.upcomingEventArray = self.eventArray
        }
    }
}



