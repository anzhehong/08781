//
//  ConnectTableViewCell.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit
import SnapKit

class ConnectTableViewCell: UITableViewCell {
    
    var title = ""
    var favorite = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, title: String, isFavorate: Bool) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.title = title
        self.favorite = isFavorate
        updateUI()
    }
    
    func updateUI() {
        self.backgroundColor = UIColor.init(red: 26/255, green: 154/255, blue: 224/255, alpha: 1.0)
        self.textLabel?.text = self.title
        self.textLabel?.textColor = UIColor.white
        initPeatch()
    }
    
    func initPeatch() {
        let imgName = self.favorite ? "favarite" : "not_favarite"
        let peachImgView = UIImageView(image: UIImage(named: imgName))
        self.addSubview(peachImgView)
        peachImgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
