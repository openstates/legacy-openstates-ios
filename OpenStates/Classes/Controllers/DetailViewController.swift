//
//  DetailViewController.swift
//  OpenStates
//
//  Created by Daniel Cloud on 10/1/14.
//  Copyright (c) 2014 Sunlight Foundation. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: NSDictionary? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: NSDictionary = self.detailItem {
            if let label = self.detailDescriptionLabel {
                if let titleText = detail["name"] as? String {
                    label.text = titleText
                } else {
                    label.text = "No name for this organization"
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

