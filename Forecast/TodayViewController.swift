//
//  TodayViewController.swift
//  Forecast
//
//  Created by Martin Pinka on 12.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit
import CoreLocation
class TodayViewController: UIViewController, UIAlertViewDelegate {


    @IBOutlet var cityLbl : UILabel!
    @IBOutlet var locationImage : UIImageView!
    @IBOutlet var weatherImage : UIImageView!
    @IBOutlet var tempAndDescriptionLbl : UILabel!
    @IBOutlet var rainLbl : UILabel!
    @IBOutlet var humidityLbl : UILabel!
    @IBOutlet var pressureLbl : UILabel!
    @IBOutlet var windSpeedLbl : UILabel!
    @IBOutlet var windDirectionLbl : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.tabBarController?.navigationController?.navigationBarHidden = false;

                
        NSNotificationCenter.defaultCenter().addObserverForName("possibleCitiesUpdated", object: nil, queue: nil) { (notf) -> Void in 
            self.reloadData()   //its caled on location changed
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false;
        
        if let token = FBSDKAccessToken.currentAccessToken() {
            RequestManager.sharedInstance // to initialize if token is known
            reloadData()
        } else {
            askForFBPermision()
        }

        
    }
    
    func reloadData () {

            RequestManager.sharedInstance.getTodaysWeather({ (city) -> Void in

                var string : String? = city.name
                if (city.country != nil && count(city.country!) > 0) {
                    string = string?.stringByAppendingFormat(", %@", city.country!)
                } 
                self.cityLbl.text = string
                if var temp =  city.weather?.temp {
                    if RequestManager.sharedInstance.tempUnit == "imperial" {
                        self.tempAndDescriptionLbl.text = "" + String(format:"%.0f", city.weather!.temp! * 9/5 + 32) + "°F" +  " | " + city.weather!.description!
                    } else {
                        self.tempAndDescriptionLbl.text = "" + String(format:"%.0f", city.weather!.temp!) + "°C" +  " | " + city.weather!.description!
                    }
                }
                if let humidity = city.weather!.humidity {
                    self.humidityLbl.text = String(format: "%ld%%", humidity)
                } else {
                    self.humidityLbl.text = String(format: "-")
                }
                
                if let pressure = city.weather!.pressure {
                    self.pressureLbl.text = String(format:"%.1f hPa", pressure)
                } else {
                    self.pressureLbl.text = "-"
                }
                
                if let speed = city.weather!.windSpeed {
                    
                    if RequestManager.sharedInstance.lengthUnit == "imperial" {
                        self.windSpeedLbl.text = String(format:"%.1f m/h", speed * 0.621371192) 
                    } else {
                        self.windSpeedLbl.text = String(format:"%.1f km/h", speed)
                    }
                    
                } else {
                    self.windSpeedLbl.text = "-"
                }
                
                if let direct = city.weather!.windDirect {
                    var string : String = "-"
                    if (direct >= 0 && direct < 45.0 || direct > 315) { //set direction of wind
                        string = "N" 
                    } else if (direct >= 45 && direct < 135){
                        string = "E"
                    } else if (direct >= 135 && direct < 225) {
                        string = "S"
                    } else if (direct >= 225 && direct < 315) {
                        string = "W"
                    }
                    
                    self.windDirectionLbl.text = string
                    
                } else {
                    self.windSpeedLbl.text = "-"
                }
            })

        
    }
    
    @IBAction func share (sender : UIButton) {
        
        if let text = self.cityLbl.text {
            let objects = [text]
            let activity =  UIActivityViewController(activityItems: objects, applicationActivities: nil)
            
            self.presentViewController(activity, animated: true, completion: nil)
        }
    }
    
    func askForFBPermision () {
        
        var login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], handler: { (result, error) -> Void in
            var r : FBSDKLoginManagerLoginResult = result
            if (!r.isCancelled)  {
               // NSLog("%@", r.token.userID)
                RequestManager.sharedInstance // to initialize
            } else {
                
                var alert : UIAlertView = UIAlertView(title: "Facebook is needed to store settings of the app", message: "If you won't give permission to your facebook profile, app won't save your settings.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Grant permission")
                alert.show()
                
            }
            
            
            //facebook's viewcontroller cancels the asking for permission, so we have to ask again
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted) { 
                if let app : AppDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    //app.locManager.delegate = app
                    app.locManager.requestWhenInUseAuthorization()
                    app.locManager.startUpdatingLocation()

                }
                
            }
            
        })
    }
        
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        
        switch (buttonIndex)  {
        case 1: //asking for permission when user cancels it 
            askForFBPermision();
            break;
        default:
            break;
        }
    }
    
    deinit {
         NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

