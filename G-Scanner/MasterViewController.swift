//
//  MasterViewController.swift
//  G-Scanner
//
//  Created by Nikhil Gohil on 23/01/2019.
//  Copyright © 2019 Gohil. All rights reserved.
//

import UIKit
import AVFoundation

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "G-Scanner"
        
        insertAllObject()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func insertAllObject() {
        objects = ["All Types of Code",AVMetadataObject.ObjectType.upce.rawValue,
                         AVMetadataObject.ObjectType.code39.rawValue,
                         AVMetadataObject.ObjectType.code39Mod43.rawValue,
                         AVMetadataObject.ObjectType.code93.rawValue,
                         AVMetadataObject.ObjectType.code128.rawValue,
                         AVMetadataObject.ObjectType.ean8.rawValue,
                         AVMetadataObject.ObjectType.ean13.rawValue,
                         AVMetadataObject.ObjectType.aztec.rawValue,
                         AVMetadataObject.ObjectType.pdf417.rawValue,
                         AVMetadataObject.ObjectType.itf14.rawValue,
                         AVMetadataObject.ObjectType.dataMatrix.rawValue,
                         AVMetadataObject.ObjectType.interleaved2of5.rawValue,
                         AVMetadataObject.ObjectType.qr.rawValue]
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! String
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}

