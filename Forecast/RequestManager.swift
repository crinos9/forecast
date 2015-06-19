//
//  RequestManager.swift
//  Forecast
//
//  Created by Martin Pinka on 13.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation
import CoreLocation

class RequestManager {
    
    
    static let sharedInstance = RequestManager()
    var firebase : Firebase = Firebase(url: "https://fiery-fire-875.firebaseio.com/")
    var firebaseCities : Firebase?
    var firebaseLength : Firebase?
    var firebaseTemp : Firebase?
    
    var lengthUnit : String?
    var tempUnit : String?
    var lastCities : NSArray?
    var citiesWeather : Array<City>?
    var currentPossibleCities : Array<City>?
    
    var chosenCity : Int = -1
    
    init() {
        
        firebase.authWithOAuthProvider("facebook", token: FBSDKAccessToken.currentAccessToken().tokenString,
            withCompletionBlock: { error, authData in
                self.firebaseCities = self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).childByAppendingPath("cities") 
                
                self.firebaseCities!.observeEventType(.Value, withBlock: { snapshot in
                    self.lastCities = snapshot.value as? NSArray
                    
                    
                    if self.lastCities != nil  {
                        self.getWeatherAtCities(self.lastCities!, completion: { (weather) -> Void in
                            self.citiesWeather = weather
                            NSNotificationCenter.defaultCenter().postNotificationName("weatherCitiesChanged", object: self)
                        })
                    }
                })
                
                
                self.firebaseLength = self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).childByAppendingPath("length_unit")
                self.firebaseLength!.observeEventType(.Value, withBlock: { snapshot in 
                    if let  unit = snapshot.value as? String {
                        if (unit == "Meters") {
                            self.lengthUnit = "metric"
                        } else if (unit == "Miles") {
                            self.lengthUnit = "imperial"
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("weatherCitiesChanged", object: self)
                    NSNotificationCenter.defaultCenter().postNotificationName("possibleCitiesUpdated", object: self)
                })
                
                self.firebaseTemp = self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).childByAppendingPath("temp_unit")
                self.firebaseTemp!.observeEventType(.Value, withBlock: { snapshot in 
                    
                    
                    if let  unit = snapshot.value as? String {
                        if (unit == "Celsius") {
                            self.tempUnit = "metric"
                        } else if (unit == "Fahrenheit") {
                            self.tempUnit = "imperial"
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName("weatherCitiesChanged", object: self)
                        NSNotificationCenter.defaultCenter().postNotificationName("possibleCitiesUpdated", object: self)
                    }
                    
                })
                
                
        })
        
        
        
        

    }
    
    
    func searchCityWithName(name : String, completion: ((Array<City>) -> Void)?) {

        
        var string_url : String = "http://api.openweathermap.org/data/2.5/find?q="
        string_url = string_url.stringByAppendingString(name)
        
        string_url = string_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        if let url = NSURL(string:String(string_url)) {
            
            var manager = AFHTTPRequestOperationManager()
            manager.GET(string_url, parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                
                var array : Array <City> = Array()
               
                
            
                if let json = response as? NSDictionary {
                    var count : Int = json["count"]!.integerValue
                    if  count > 0 {
                        for var index = 0; index < count; ++index {
                            if let list : NSArray = json["list"] as? NSArray {
                                var city : City = City ( id: (list[index]["id"] as? Int), 
                                    name: (list[index]["name"] as? String),
                                    country: (list[index]["sys"] as? NSDictionary )?["country"] as? String)
                                array.append(city)
                            }
                        }
                    }
                }
                
                //
                if (completion != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        completion!(array)
                    })
                }
                
                }, failure: nil);
        }
    }
    
    func getWeatherAtCities(cityIds : NSArray, completion: ((Array<City>) -> Void)?) {
        
       // NSLog("get")
        var string_url : String = "http://api.openweathermap.org/data/2.5/group?id="
//        string_url = string_url.stringByAppendingString(name)
        for cityID in cityIds {
            if let number = cityID as? NSNumber {
               string_url = string_url.stringByAppendingFormat("%ld,", number.integerValue)
            }
        }
        
        string_url = string_url.stringByAppendingFormat("&units=metric")
        string_url = string_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        if let url = NSURL(string:String(string_url)) {
            
            var manager = AFHTTPRequestOperationManager()
            manager.GET(string_url, parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                
                var array : Array <City> = Array()
                
                
                
                if let json = response as? NSDictionary {
                    var count : Int = json["cnt"]!.integerValue
                    if  count > 0 {
                        for var index = 0; index < count; ++index {
                            if let list : NSArray = json["list"] as? NSArray {
                                if let cityDict : NSDictionary = list[index] as? NSDictionary {

                                        array.append(self.parseCity(cityDict))
                                }

                            }
                            
                            
                        }
                    }
                }
                
                //
                if (completion != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        completion!(array)
                    })
                }
                
                }, failure: nil);
        }
    }
    
    func getWeatherAtPlaceByLoc (location : CLLocation!) {
        
            
            var string_url : String = "http://api.openweathermap.org/data/2.5/find?"

            
            string_url = string_url.stringByAppendingFormat("lat=%f&lon=%f", location.coordinate.latitude, location.coordinate.longitude)
        
            string_url = string_url.stringByAppendingFormat("&units=metric")
            string_url = string_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
            if let url = NSURL(string:String(string_url)) {
            
                var manager = AFHTTPRequestOperationManager()
                manager.GET(string_url, parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                
                    if let json = response as? NSDictionary {
                        var count : Int = json["count"]!.integerValue
                        if  count > 0 {
                            
                            
                            self.currentPossibleCities = Array<City>()
                            
                            for var index = 0; index < count; ++index {
                                
                                if let list : NSArray = json["list"] as? NSArray {
                                    var city : City = self.parseCity(list[index] as! NSDictionary)
                                    self.currentPossibleCities?.append(city)
                                    
                                }
                            
                            }
                    }
                }
                
                //
                   /* if (completion != nil) 
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                        
                            completion!(array)
                        })
                    }*/
                NSNotificationCenter.defaultCenter().postNotificationName("possibleCitiesUpdated", object: self)
                    }, failure: nil);
            }
       
        
        
    }
    
    func getDailyForecastForCurrentCity(completion: ((City) -> Void)?) {
        
        var string_url : String = "http://api.openweathermap.org/data/2.5/forecast/daily?id="

        var city : City?
        
        if (chosenCity >= 0) {
            city = citiesWeather![chosenCity]
        } else {
            if (currentPossibleCities?.count > 0 ) {
                city = currentPossibleCities![0]
            } else {
                return
            }
            
        }
        
        string_url = string_url.stringByAppendingFormat("%ld",city!.id!)

        string_url = string_url.stringByAppendingFormat("&cnt=7&units=metric")
        string_url = string_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        if let url = NSURL(string:String(string_url)) {
            
            var manager = AFHTTPRequestOperationManager()
            manager.GET(string_url, parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                
                if let json = response as? NSDictionary {
                    
                    var count : Int = json["cnt"]!.integerValue
                    if  count > 0 {
                        var forecast : Array<Weather> = Array<Weather>()
                        if let list : NSArray = json["list"] as? NSArray {
                            for var index = 0; index < count; ++index {
                            

                             
                               var weather : Weather = self.parseForecastWeather(list[index] as! NSDictionary)
                               forecast.append(weather) 
                                
                            }
                            
                        }
                        city?.forecast = forecast
                        if completion != nil {
                            completion!(city!)
                        }
                    }
                }
        
                }, failure: nil);
        }
    }
    
    func addCity(cityId : Int) {
        
        if let updatedArray : NSMutableArray = lastCities?.mutableCopy() as? NSMutableArray {
            var found = false
            for num  in updatedArray {
                if let number = num.integerValue {
                    if (number == cityId) {
                        found = true
                        break
                    }
                }
            }
            
            if (!found) {
                updatedArray.addObject(cityId)
                firebaseCities!.setValue(updatedArray)
            }
            

        } else {
            firebaseCities!.setValue([cityId])
        }
    }
    
    func deleteCity(cityId : Int) {
      
        if let updatedArray : NSMutableArray = lastCities?.mutableCopy() as? NSMutableArray {
            var found = false
            var index = -1
            for num  in updatedArray {
                if let number = num.integerValue {
                    if (number == cityId) {
                        found = true
                        index = updatedArray.indexOfObject(num)
                        break
                    }
                }
            }
            
            if (found && index >= 0) {
                updatedArray.removeObjectAtIndex(index)
                firebaseCities!.setValue(updatedArray)
                
                if (lastCities?.count == 1) { //rewrite with empty array 
                    lastCities = nil
                    citiesWeather = nil
                    chosenCity = -1
                    NSNotificationCenter.defaultCenter().postNotificationName("weatherCitiesChanged", object: self)
                }

            }

            
        } else { //nothing to delete
            
        }
    }
    
    func setLenghtUnits(unit : String) {
        var fb = self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).childByAppendingPath("length_unit")
        fb.setValue(unit)
    }
    
    func setTempUnit(unit : String) {
        var fb = self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).childByAppendingPath("temp_unit")
        fb.setValue(unit)
    }
    
    func getTodaysWeather(completion : ((City) -> Void)!) {
        
        if (citiesWeather?.count > 0 && chosenCity >= 0) {
            completion(citiesWeather![chosenCity])
        } else {
            if (currentPossibleCities?.count > 0) {
                if let city : City = currentPossibleCities?[0] {
                    completion(city)
                }   
            }
        }
        
        
    }
    
    private func parseCity (cityDict : NSDictionary) -> City {
       
        var city : City = City ( id: (cityDict["id"] as? Int),
            name: (cityDict["name"] as? String),
            country: (cityDict["sys"] as? NSDictionary )?["country"] as? String)
        
        var weather : Weather = Weather()
        if let main : NSDictionary = cityDict["main"] as? NSDictionary {
            weather.temp = main["temp"]!.floatValue!//String(format: "%ld", main["temp"]!.integerValue!)
            weather.humidity = main["humidity"] as? Int
            weather.pressure = main["pressure"] as? Float
        }
        if let weatherAr : NSArray = (cityDict["weather"] as? NSArray) {
            if let weatherDict : NSDictionary = weatherAr[0] as? NSDictionary {    
                weather.description = weatherDict["description"] as? String
                weather.icon = self.getIconForName(weatherDict["icon"] as! String!)
                
            }
        }
        
        if let windDict = cityDict["wind"] as? NSDictionary {
            weather.windSpeed = windDict["speed"] as? Float
            weather.windDirect = windDict["deg"] as? Float
        }
        
        city.weather = weather
        return city
    }
    
    
    private func parseForecastWeather(weatherDict : NSDictionary) -> Weather {
        var weather : Weather = Weather()
        if let temps = weatherDict["temp"] as? NSDictionary { 
            if let tempDay = temps["day"] as? Float{
                weather.temp = tempDay//String(format: "%ld", tempDay)
            }
        }
        
        if let weatherArr = weatherDict["weather"] as? NSArray { 
            if let weatherD = weatherArr[0] as? NSDictionary {
                if let descrip = weatherD["description"] as? String {
                    weather.description = descrip
                }
                
                
                if let icon = weatherD["icon"] as? String {
                    weather.icon = self.getIconForName(icon)
                }
            }
        }
        if let dt = weatherDict["dt"] as? Int {
            weather.day = getDay(dt)
        }
        
        return weather
    }

    private func getDay (date:Int) -> String {
        var time : Double = Double(date)
        var date = NSDate(timeIntervalSince1970: time)
        var df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US")
        df.dateFormat = "EEEE"
        
        return df.stringFromDate(date)
    }
    
    private func getIconForName(iconName : String) -> String {
        
        switch(iconName) {
            case "01d", "01n": 
                return "Sun"
            case "02d", "02n", "03d", "03n", "04d", "04n":
                return "CS"
            case "11d,11,n":
                return "CL"
            case  "09d","09n", "10d", "10n":
                return "Rain"
            default:
                return ""
        }
        
        
    }

    
}