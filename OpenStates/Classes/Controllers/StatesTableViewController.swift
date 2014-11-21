//
//  StatesTableViewController.swift
//  OpenStates
//
//  Created by Daniel Cloud on 11/10/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit

protocol StateSelectionDelegate {
    func stateSelection(controller: StatesTableViewController, division:Division)
}

class StatesTableViewController: UITableViewController {
    var dataManager: StatesDataManager? {
        didSet {
            self.tableView.dataSource = self.dataManager
        }
    }
    var selectionDelegate: StateSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.dataManager = StatesDataManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let manager = self.dataManager {
            if let selection:Division = manager.divisionForIndexPath(indexPath) {
                if let delegate = self.selectionDelegate {
                    delegate.stateSelection(self, division: selection)
                }
            }
        }
    }


}
