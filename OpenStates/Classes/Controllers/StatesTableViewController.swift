//
//  StatesTableViewController.swift
//  OpenStates
//
//  Created by Daniel Cloud on 11/10/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit

protocol StateSelectionDelegate {
    func stateSelection(controller: StatesTableViewController, stateSelected:String)
}

class StatesTableViewController: UITableViewController {
    // TODO: Get other source of state abbreviations and put into plist or something.
    let objects: [String] = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    var selectionDelegate: StateSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatesTableCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        let item = objects[indexPath.row]
        cell.textLabel.text = item

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selection = self.objects[indexPath.row]
        if let delegate = selectionDelegate {
            delegate.stateSelection(self, stateSelected: selection)
        }
    }

}
