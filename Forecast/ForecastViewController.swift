//
//  ForecastViewController.swift
//  Forecast
//
//  Created by Martin Pinka on 18.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class ForecastViewController : UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    private var city : City?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        RequestManager.sharedInstance.getDailyForecastForCurrentCity({(data) -> Void in 
            self.city = data
            self.tableView.reloadData()
            self.navigationItem.title = self.city!.name
            
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let count = city?.forecast?.count {
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! LocationCell
        
        if let weather = city?.forecast?[indexPath.row] {
            if let day = weather.day {
                cell.cityLbl.text = day
            }
            if let descrip =  weather.description {
                cell.weatherLbl.text = descrip
            }
            if let icon = weather.icon {
                cell.weatherImg.image = UIImage(named:icon)
            }
            if let temp = weather.temp {
                if (RequestManager.sharedInstance.tempUnit == "metric") {
                    cell.tempLbl.text = String(format:"%.0f°", temp)
                } else {
                    cell.tempLbl.text = String(format:"%.0f°", temp * 9/5 + 32)
                }
                
            }
            cell.weatherImg.image = UIImage(named: weather.icon!)
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    
}