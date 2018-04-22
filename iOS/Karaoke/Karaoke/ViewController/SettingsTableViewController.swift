//
//  SettingsTableViewController.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let cellTexts = ["Profile", "Effects", "Recordings", "About"]

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(SettingsProfileTableViewCell.self, forCellReuseIdentifier: "settingsProfileTableViewCell")
        self.tableView.register(UINib(nibName: "SettingsProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "settingsProfileTableViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.backgroundColor = UIColor(red: 243/243, green: 243/243, blue: 243/243, alpha: 1.0)
        self.tableView.isScrollEnabled = false
        
        
        
//        let label = UILabel()
//        label.text = "❤️ powered by Friendaoke"
//        view.addSubview(label)
//        label.snp.makeConstraints { (make) in
//            make.center.equalTo(view)
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellTexts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor  = UIColor.black
//        self.tableView.addSubview(container)
//        container.snp.makeConstraints { (make) in
//            make.leading.trailing.equalTo(self.tableView)
//            make.bottom.equalTo(tableView.snp.centerY)
//            make.height.equalTo(50)
//        }
        return container
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
//            let cell: SettingsProfileTableViewCell = SettingsProfileTableViewCell.fromNib()
            let cell: SettingsProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingsProfileTableViewCell", for: indexPath) as! SettingsProfileTableViewCell
            cell.backgroundColor = UIColor(red: 243/243, green: 243/243, blue: 243/243, alpha: 1.0)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.backgroundColor = UIColor(red: 243/243, green: 243/243, blue: 243/243, alpha: 1.0)
    
        // Configure the cell...
        cell.textLabel?.text = cellTexts[indexPath.row]

        return cell
    }
}
