//
//  Configuration.swift
//  OpenStates
//
//  Created by Daniel Cloud on 11/7/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import Foundation

class AppConfiguration {
    let propertyList:NSDictionary?

    var ocdApiKey:String? {
        if let key = self.propertyList?.valueForKey("kOCDApiKey") as? String {
            return key
        } else {
            return nil
        }
    }

    init() {
        let bundle = NSBundle.mainBundle()
        var resourceURL:NSURL? = bundle.URLForResource("ApiKeys", withExtension: "plist")

        if let resourceURL = resourceURL {
            var data:NSData = NSData(contentsOfURL: resourceURL)!
            self.propertyList = NSPropertyListSerialization.propertyListWithData(data, options: 0, format: nil, error: nil) as? NSDictionary
        }
    }

}