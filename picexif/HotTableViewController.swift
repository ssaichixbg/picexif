//
//  HotTableViewController.swift
//  picexif
//
//  Created by Simon on 04/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import JGProgressHUD

class HotTableViewController: PETableViewController {
    var locationList = [String: [POI]]()
    var onSelectPOI: ((POI)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        updateData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return locationList.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryName = Array(locationList.keys)[section]
        return locationList[categoryName]!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath)
        
        let categoryName = Array(locationList.keys)[indexPath.section]
        
        cell.textLabel?.text = locationList[categoryName]?[indexPath.row].name
        cell.detailTextLabel?.text = locationList[categoryName]?[indexPath.row].address

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = navigationController?.popViewController(animated: true)
        let categoryName = Array(locationList.keys)[indexPath.section]

        onSelectPOI?(locationList[categoryName]![indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categoryName = Array(locationList.keys)[section]
        return categoryName
    }
    
    func updateData() {
        let hud = JGProgressHUD(style: .dark)!
        hud.textLabel.text = "正在寻找最热位置..."
        hud.show(in: navigationController?.view)
        _ = POI.hotList(onSuccess: { [weak self] (list) in
                self?.locationList = list
                self?.tableView.reloadData()
                hud.dismiss()
        }, onError: { msg in
            hud.textLabel.text = "没找到:( 请稍后再试"
            hud.dismiss(afterDelay: 1.0)
        })
    }
}
