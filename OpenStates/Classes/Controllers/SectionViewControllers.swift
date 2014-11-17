//
//  SectionViewControllers.swift
//  OpenStates
//
//  Created by Daniel Cloud on 10/1/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit

class SectionViewController: UITableViewController, StateSelectionDelegate {

    var detailViewController: DetailViewController? = nil
    var dataManager: OpenCivicDataManager? {
        didSet {
            self.tableView.dataSource = self.dataManager
        }
    }
    @IBOutlet weak var titleViewButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataManager = OpenCivicDataManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                if let ocdSource = self.tableView.dataSource as? OpenCivicDataManager {
                    let item = ocdSource.itemForIndexPath(indexPath)
                    controller.detailItem = item
                }
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showStatesTable" {
            if let controller = segue.destinationViewController as? StatesTableViewController {
                controller.selectionDelegate = self
            }
        }
    }

    //MARK: - StateSelectionDelegate

    func stateSelection(controller: StatesTableViewController, stateSelected: String) {
        println("Selected \(stateSelected)")
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.titleViewButton.setTitle(stateSelected, forState: UIControlState.Normal)
    }

}

class LegislatorSectionViewController: SectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataManager = LegislatorDataManager()
    }

    override func stateSelection(controller: StatesTableViewController, stateSelected: String) {
        super.stateSelection(controller, stateSelected: stateSelected)
        if let dataManager = self.dataManager {
            dataManager.fetchItems { (items, error) in
                println("Fetched items")
                self.tableView.reloadData()
            }
        }
    }
}

