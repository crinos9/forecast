
//  SearchResultsViewController.swift
//  Forecast
//
//  Created by Martin Pinka on 13.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation
import UIKit
class SearchResultsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet var tableView : UITableView!
    @IBOutlet var activityIndic : UIActivityIndicatorView!
    var cities : Array<City>?
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
                
       // NSLog("%@", searchController.searchBar.text)
        if (count(searchController.searchBar.text) > 3) {
            self.activityIndic.startAnimating()

            RequestManager.sharedInstance.searchCityWithName(searchController.searchBar.text,completion: {(data) -> Void in 
               
                self.activityIndic.stopAnimating()

                      self.cities = data
                      self.tableView.reloadData()
//                    NSLog("data:%@",  NSString(data: data, encoding: NSUTF8StringEncoding)!)
            
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.activityIndic.stopAnimating();
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cities != nil {
            return cities!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell =  tableView.dequeueReusableCellWithIdentifier("CityCell") as! UITableViewCell
        

        var city : City? = cities?[indexPath.row]

        
        var string : String?
        
        
        =  String(format: "%@, %@", city!.name!, city!.country!)
        
        cell.textLabel?.text = string
        if string != nil {
            var stringAtr : NSMutableAttributedString? = NSMutableAttributedString(string: string!)
            
            var attr  = [NSFontAttributeName : UIFont.boldSystemFontOfSize(19)]
            
            stringAtr?.addAttributes(attr, range: NSMakeRange(0, count(city!.name!)))
            
            cell.textLabel?.attributedText = stringAtr!
        }
            
            
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let city = cities?[indexPath.row] {
            RequestManager.sharedInstance.addCity(city.id!)
        }
    
    }
}