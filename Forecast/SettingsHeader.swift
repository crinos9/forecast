//
//  SettingsHeader.swift
//  Forecast
//
//  Created by Martin Pinka on 13.06.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SettingsHeader: UIView {
    
    class func instanceFromNib() -> SettingsHeader {
        return UINib(nibName: "SettingsHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! SettingsHeader
    }
    
}