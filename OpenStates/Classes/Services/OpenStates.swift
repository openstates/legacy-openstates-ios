//
//  OpenStates.swift
//  OpenStates
//
//  Created by Daniel Cloud on 11/20/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import Foundation
import OCDKit

class OCDObject {
    let id: String

    init(id: String) {
        self.id = id
    }
}

class Division: OCDObject {
    let name: String

    init(id: String, name: String) {
        self.name = name
        super.init(id: id)
    }

    func isState() -> Bool {
        let identifer = self.id as NSString
        let range: NSRange = identifer.rangeOfString("/state:")
        return range.location != NSNotFound
    }
}

class DivisionInfo {
    let divisions: [Division] = []

    init() {
        // get states items from the plist
        let bundle = NSBundle.mainBundle()
        if let filePath = bundle.pathForResource("States", ofType: "plist") {
            if let states = NSArray(contentsOfFile: filePath) {
                for s in states {
                    if let dict = s as? Dictionary<String, String> {
                        if let id: String = dict["id"] {
                            let obj = Division(id: id, name: dict["name"] ?? "")
                            self.divisions.append(obj)
                        }
                    }
                }
            }
        }
    }

    func lookupDivision(id: String) -> Division? {
        let candidates = self.divisions.filter({ s in
            return s.id == id
        })
        if candidates.count == 1 {
            return candidates.first
        }
        return nil
    }

    func nonStates() -> [Division] {
        return self.divisions.filter({ s in
            return s.isState() == false
            }).sorted({ s1, s2 in
                return s1.name < s2.name
            })
    }

    func statesOnly() -> [Division] {
        return self.divisions.filter { s in
            return s.isState() == true
        }
    }
}

class OpenStates {
    let api: OpenCivicData
    lazy var divisions: DivisionInfo = DivisionInfo()

    init() {
        let config = AppConfiguration()
        let apiKey = config.ocdApiKey!
        self.api = OpenCivicData(apiKey: apiKey)
    }
}
