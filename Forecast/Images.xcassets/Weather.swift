//
//  Weather.swift
//  Forecast
//
//  Created by Martin Pinka on 19.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation

class Weather {
    
    var day : String?
    var temp : Float?
    var weather : String?
    var description : String?
    var icon : String?
    var humidity : Int?
    var pressure : Float?
    var windSpeed : Float?
    var windDirect : Float?
    init( temp : Float? = nil, weather : String? = nil, description : String? = nil, icon : String? = nil) {
        self.temp = temp
        self.weather = weather
        self.description = description
        self.icon = icon
        
        
    }
    
}