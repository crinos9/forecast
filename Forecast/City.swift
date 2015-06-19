//
//  City.swift
//  Forecast
//
//  Created by Martin Pinka on 19.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import Foundation


class City {
    
    var id : Int?
    var name : String?
    var country : String?
    var current : Bool
    var weather : Weather? //current
    var forecast : Array<Weather>?
    
    init(id : Int?, name : String?, country : String?, current : Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.current = current
    }
    
    
    
    
    
}