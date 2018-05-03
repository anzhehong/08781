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
    var player: AVAudioPlayer?

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
        return container
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(indexPath.section)
        if indexPath.section == 0 && indexPath.row == 2 {
            popupRecordings()
        }
    }
    
    func popupRecordings() {
        let alert = UIAlertController(title: "Recordings", message: "Click play to play the recorded file if you have recorded.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play", style: .destructive, handler: { (alert) in
            DispatchQueue.main.async {
                self.playRecording()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func playRecording() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (path as NSString).appendingPathComponent("soundtouch.wav")
        guard let audioData = NSData(contentsOfFile: filePath) else {
            print("error fetching")
            return
        }
        
        var format = AudioStreamBasicDescription()
        format.mFormatID = kAudioFormatLinearPCM
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        format.mSampleRate = 44100.0
        format.mBitsPerChannel = 16
        format.mChannelsPerFrame = 1
        format.mBytesPerPacket = (format.mBitsPerChannel / 8) * format.mChannelsPerFrame
        format.mBytesPerFrame = (format.mBitsPerChannel / 8) * format.mChannelsPerFrame
        format.mFramesPerPacket = 1
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            player?.stop()
            player = try AVAudioPlayer(pcmData: Data(referencing: audioData), pcmFormat: format)
            player?.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
