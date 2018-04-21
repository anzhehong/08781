//
//  ConnectViewController.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var data1 = (name: "Bryant's Macbook Pro", favorite: true)
    var data2 = (name: "David's Lenovo", favorite: false)
    var data3 = (name: "Stephon's PC", favorite: true)
    var defaultConnections: [(name: String, favorite: Bool)] =  []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultConnections.append(data1)
        defaultConnections.append(data2)
        defaultConnections.append(data3)
        tableView.backgroundColor = UIColor.init(red: 26/255, green: 154/255, blue: 224/255, alpha: 1.0)
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultConnections.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = ConnectTableViewCell(style: .default, reuseIdentifier: "default", title: defaultConnections[indexPath.row].name, isFavorate: defaultConnections[indexPath.row].favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
