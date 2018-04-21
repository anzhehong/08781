//
//  AlbumTableTableViewController.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit
import SwipeCellKit

class AlbumTableTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var dataCollection: [(name: String, singer: String, album: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.addTarget(self, action: #selector(segmentTouched), for: .valueChanged)
        initFakeData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    @objc func segmentTouched() {
        
        print("touched \(segmentControl.selectedSegmentIndex)")
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
        return dataCollection.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell: AlbumTableViewCell = AlbumTableViewCell.fromNib()
        cell.delegate = self
        cell.nameLabel.text = dataCollection[indexPath.row].name
        cell.singerLabel.text = dataCollection[indexPath.row].singer
        cell.albumImageView.image = UIImage(named: dataCollection[indexPath.row].album)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        // customize the action appearance
//        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func initFakeData() {
        dataCollection.append((name: "Lights Down Low", singer: "Max", album: "album1"))
        dataCollection.append((name: "Mine", singer: "Bazzi", album: "album2"))
        dataCollection.append((name: "God's Plan", singer: "Drake", album: "album3"))
        dataCollection.append((name: "Let You Know", singer: "NF", album: "album4"))
        dataCollection.append((name: "Pray For Me", singer: "ED Sheeran", album: "album5"))
        dataCollection.append((name: "Listen to Your Mother", singer: "Jay Chou", album: "album6"))
        dataCollection.append((name: "Black Sweater", singer: "Jay Chou", album: "album7"))
    }
}
