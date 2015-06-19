//
//  SettingsViewController.swift
//  Forecast
//
//  Created by Martin Pinka on 12.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController{
    
    var unitsLength = ["Meters", "Miles"]
    var unitsTemp = ["Celsius", "Fahrenheit"]
    
    var usedLenghtUnit : String = ""
    var usedTempUnit : String = ""
    

    
    override func viewDidLoad() {

    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("settingCell") as! SettingsCell
//        cell.button.addTarget(self, action: "settingChanged:", forControlEvents: UIControlEvents.TouchUpInside)
        
        switch (indexPath.row) {
            case 0: //setting of length unit
                cell.name.text = "Units  of lenght"
                if let unit = RequestManager.sharedInstance.lengthUnit {
                    if unit == "imperial" {
                        usedLenghtUnit = "Miles"
                    } else {
                        usedLenghtUnit = "Meters"
                    }
                    cell.button.setTitle(usedLenghtUnit, forState: UIControlState.Normal)   
                } else {
                    usedLenghtUnit = unitsLength[0]
                    cell.button.setTitle(usedLenghtUnit, forState: UIControlState.Normal)       
                }
                
                break;
            case 1: //setting of temp unit
                cell.name.text = "Units  of temperature" 
                if let unit = RequestManager.sharedInstance.tempUnit {
                    if unit == "imperial" {
                        usedTempUnit = "Fahrenheit"
                    } else {
                        usedTempUnit = "Celsius"
                    }
                    cell.button.setTitle(usedTempUnit, forState: UIControlState.Normal)
                } else {
                    usedTempUnit = unitsTemp[0]
                    cell.button.setTitle(usedTempUnit, forState: UIControlState.Normal)
                }
                break;
            default:
                break;
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = SettingsHeader.instanceFromNib()
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
  
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! SettingsCell
      //  var index : AnyObject
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var newIndex = 0
        switch (indexPath.row) {
            case 0:
                
                var index  = find(unitsLength, usedLenghtUnit)!
                newIndex = 1 - index
                usedLenghtUnit = unitsLength[newIndex]
                RequestManager.sharedInstance.setLenghtUnits(usedLenghtUnit)
                break
            case 1: 
                
                var index = find(unitsTemp, usedTempUnit)!
                newIndex = 1 - index
                usedTempUnit = unitsTemp[newIndex]
                RequestManager.sharedInstance.setTempUnit(usedTempUnit)
                break
            default:
                break
        }

        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) //when cell is changed it has to be updated
    }

/*    func settingChanged (sender : UIButton) {
 
        
    }*/
 
    

}
