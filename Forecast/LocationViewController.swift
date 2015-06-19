 //
//  LocationViewController.swift
//  Forecast
//
//  Created by Martin Pinka on 12.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class LocationViewController: ForecastViewController, UISearchControllerDelegate {


    var searchController : UISearchController!
    var resultController :SearchResultsViewController!
    
    var cities : Array<City>?
    
    override func viewDidLoad() {

        self.navigationItem.hidesBackButton = true
        
        //setting up search controller
        resultController = self.storyboard?.instantiateViewControllerWithIdentifier("serachResults") as! SearchResultsViewController
        searchController = UISearchController(searchResultsController: resultController)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self;
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = resultController
        
        searchController.searchBar.barTintColor = UIColor.whiteColor()
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
    //    searchController.searchBar.setSearchFieldBackgroundImage(UIImage(), forState: UIControlState.Normal)
        searchController.searchBar.backgroundColor = UIColor.whiteColor()

        searchController.searchBar.setValue("Close", forKey: "_cancelButtonText")
        if let searchField: UITextField = searchController.searchBar.valueForKey("_searchField") as? UITextField {
            searchField.layer.borderColor = UIColor(red: 47.0/255.0, green:  145.0/255.0, blue:  255.0/255.0, alpha: 1.0).CGColor
            searchField.layer.borderWidth = 1
            searchField.layer.masksToBounds = true
            searchField.clipsToBounds = true
            searchField.layer.cornerRadius = 5
            searchField.textColor = UIColor(red: 47.0/255.0, green:  145.0/255.0, blue:  255.0/255.0, alpha: 1.0)
            searchField.backgroundColor = UIColor.whiteColor()
            searchField.borderStyle = UITextBorderStyle.None

            var img : UIImageView = (searchField.leftView as? UIImageView)!

            img.image = img.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            img.tintColor = UIColor(red: 47.0/255.0, green:  145.0/255.0, blue:  255.0/255.0, alpha: 1.0)

        
        }
        searchController.searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: 0)
        searchController.searchBar.setImage(UIImage(named: "Close"), forSearchBarIcon: UISearchBarIcon.Clear, state: UIControlState.Normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        
//        self.sendRequest()
       
        self.cities = RequestManager.sharedInstance.citiesWeather
        self.tableView.reloadData()
        
        NSNotificationCenter.defaultCenter().addObserverForName("weatherCitiesChanged", object: nil, queue: nil) { (notf) -> Void in //notified when you add new city
            //self.sendRequest()
            self.cities = RequestManager.sharedInstance.citiesWeather
            self.tableView.reloadData()
        } 
        
       
        
    }
        
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true;
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false;
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        RequestManager.sharedInstance.chosenCity = indexPath.row
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cities != nil {
            return count(cities!)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! LocationCell
        if let city : City = cities?[indexPath.row] {
            if var temp = city.weather?.temp {
                if (RequestManager.sharedInstance.tempUnit == "metric") {
                    cell.tempLbl.text = String(format:"%.0f°", temp)
                } else {
                    cell.tempLbl.text = String(format:"%.0f°", temp * 9/5 + 32)
                }
            }
            cell.cityLbl.text = city.name
            
            cell.weatherLbl.text = city.weather!.description
            cell.weatherImg.image = UIImage(named: city.weather!.icon!)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete;
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

/*        if let font = UIFont(name: "ProximaNova-Bold", size: 18) {
            UIButton.appearance().titleLabel?.font = font //didnt work
        }*/
        
        var action =  UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "  x  ", handler: { (rowAction, indexPath2) -> Void in
            if let index = self.cities?[indexPath.row].id {
                RequestManager.sharedInstance.deleteCity(index)
            }

        })
        

        action.backgroundColor = UIColor(patternImage: UIImage(named: "Delete")!)
        
        return [action]
    }
    
    
    @IBAction func openSearch(sender:UIButton) {
        //self.presentViewController(searc, animated: <#Bool#>, completion: <#(() -> Void)?##() -> Void#>)
        presentViewController(self.searchController, animated: true, completion: nil)

    }
    
    
    @IBAction func done(sender:UIButton) {
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func didDismissSearchController(searchController: UISearchController) {
      //  sendRequest()
    }
    
    func sendRequest() {
        if let cityIDs = RequestManager.sharedInstance.lastCities {
            RequestManager.sharedInstance.getWeatherAtCities(cityIDs, completion: { (cities) -> Void in
                self.cities = cities;
                self.tableView.reloadData()
            })
        } 
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    


}
