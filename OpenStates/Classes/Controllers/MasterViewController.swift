//
//  MasterViewController.swift
//  OpenStates
//
//  Created by Daniel Cloud on 10/1/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit
import OCDKit

class MasterViewController: UITableViewController, StateSelectionDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = NSMutableArray()
    var openCivicData: OpenCivicData?
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
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as NSDictionary
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showStatesTable" {
            if let controller = segue.destinationViewController as? StatesTableViewController {
                controller.selectionDelegate = self
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as NSDictionary
        if let title = object["name"] as? String {
            cell.textLabel.text = title
        }
        if let subtitle = object["id"] as? String {
            cell.detailTextLabel?.text = subtitle
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    //MARK: - StateSelectionDelegate

    func stateSelection(controller: StatesTableViewController, stateSelected: String) {
        println("Selected \(stateSelected)")
        controller.dismissViewControllerAnimated(true, completion: nil)
        self.titleViewButton.setTitle(stateSelected, forState: UIControlState.Normal)

        let config = AppConfiguration()

        let apiKey = config.ocdApiKey!

        openCivicData = OpenCivicData(apiKey: apiKey)
        let api = openCivicData!

        let jurisdiction_id = "ocd-jurisdiction/country:us/state:\(stateSelected.lowercaseString)/government"

        api.organizations(["jurisdiction_id": jurisdiction_id]).responseJSON({ (request, _, JSON, error) -> Void in

            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                let results: NSArray? = jsonResult["results"] as? NSArray
                let meta: NSDictionary? = jsonResult["meta"] as? NSDictionary
                let errorMessage = jsonResult["error"] as? String

                if let resultsList = results {
                    println("Found \(resultsList.count) results")
                    self.objects.removeAllObjects()
                    self.objects.addObjectsFromArray(resultsList)
                    self.tableView.reloadData()
                }
            }
        })


    }

}

