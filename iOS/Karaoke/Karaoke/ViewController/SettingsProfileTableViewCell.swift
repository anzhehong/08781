//
//  SettingsProfileTableViewCell.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit

class SettingsProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var avatorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
