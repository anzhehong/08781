//
//  ControlViewController.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/21/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController {
    
    var outerCircle: UIView!
    var innerCircle: UIView!
    
    var playButton: UIButton!
    var volumeUpButton: UIButton!
    var volumeDownButton: UIButton!
    var nextSongButton: UIButton!
    var previousSongButton: UIButton!
    
    var lockButton: UIButton!
    var effectButton: UIButton!
    var recordButton: UIButton!
    
    var albumImageView: UIImageView!
    var albumNameLabel: UILabel!
    var albumSingerLabel: UILabel!

    var effectEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeBlurBackground()
        
        outerCircle = makeCircle(r: 300.0, color: UIColor.blue)
        innerCircle = makeCircle(r: 100.0, color: UIColor.red)

        // Do any additional setup after loading the view.
        
        updatePanel()
        
        updateTopUI()
        updateBottomUI()
    }
    
    func makeBlurBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "album2")!)
        let blurView = UIView(frame: self.view.frame)
        self.view.addSubview(blurView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
    }
    
    func makeCircle(r: CGFloat, color: UIColor) -> UIView{
        let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: r, height: r))
        circle.center = self.view.center
        circle.layer.cornerRadius = r / 2
//        circle.backgroundColor = color
        circle.clipsToBounds = true
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        
        blurView.frame = circle.bounds
        self.view.addSubview(circle)
        
        circle.layer.borderColor = UIColor.init(red: 0/255, green: 159/255, blue: 242/255, alpha: 1.0).cgColor
        circle.layer.borderWidth = 2.0
        
//        circle.addSubview(blurView)
        return circle
    }
    
    func updatePanel() {
        let leading = 15
        let width = 40
        
        playButton = makeButton(imgName: "play_button")
        innerCircle.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(innerCircle)
            make.width.height.equalTo(width)
        }
        
        volumeUpButton = makeButton(imgName: "volume_up")
        outerCircle.addSubview(volumeUpButton)
        
        volumeDownButton = makeButton(imgName: "volume_down")
        outerCircle.addSubview(volumeDownButton)
        
        nextSongButton = makeButton(imgName: "next_song")
        outerCircle.addSubview(nextSongButton)
        
        previousSongButton = makeButton(imgName: "previous_song")
        outerCircle.addSubview(previousSongButton)
        
        
        
        volumeUpButton.snp.makeConstraints { (make) in
            make.top.equalTo(outerCircle).offset(leading)
            make.centerX.equalTo(outerCircle)
            make.width.height.equalTo(width)
        }
        
        volumeDownButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(outerCircle).offset(-leading)
            make.centerX.equalTo(volumeUpButton)
            make.width.height.equalTo(volumeUpButton)
        }
        
        nextSongButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(outerCircle).offset(-leading)
            make.centerY.equalTo(outerCircle)
            make.width.height.equalTo(volumeUpButton)
        }
        
        previousSongButton.snp.makeConstraints { (make) in
            make.leading.equalTo(outerCircle).offset(leading)
            make.centerY.equalTo(outerCircle)
            make.width.height.equalTo(volumeUpButton)
        }
    }
    
    func updateTopUI() {
        let container = UIView()
        self.view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(80)
            make.trailing.leading.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        albumImageView = UIImageView(image: UIImage(named: "album2"))
        container.addSubview(albumImageView)
        
        albumNameLabel = UILabel()
        albumNameLabel.text = "Let You Know"
        albumNameLabel.textColor = UIColor.white
        container.addSubview(albumNameLabel)
        
        albumSingerLabel = UILabel()
        albumSingerLabel.text = "NF"
        albumSingerLabel.textColor = UIColor.white
        container.addSubview(albumSingerLabel)
        
        lockButton = makeButton(imgName: "locker_locked")
        container.addSubview(lockButton)
        lockButton.addTarget(self, action: #selector(lockScreen), for: .touchUpInside)
        
        let leading = 10
        albumImageView.snp.makeConstraints { (make) in
            make.top.equalTo(container).offset(leading)
            make.bottom.equalTo(container).offset(-leading)
            make.leading.equalTo(container).offset(leading)
            make.height.equalTo(albumImageView.snp.width)
        }
        
        albumNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(albumImageView.snp.trailing).offset(leading*2)
            make.bottom.equalTo(albumImageView.snp.centerY).offset(-5)
        }
        
        albumSingerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(albumImageView.snp.centerY).offset(5)
            make.leading.equalTo(albumNameLabel)
        }
        
        lockButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(container).offset(-leading)
            make.centerY.equalTo(container)
            make.height.width.equalTo(40)
        }
    }
    
    func updateBottomUI() {
        recordButton = makeButton(imgName: "record")
        self.view.addSubview(recordButton)
        effectButton = makeButton(imgName: "voice_effect")
        self.view.addSubview(effectButton)
        effectButton.addTarget(self, action: #selector(changeEffectStatus), for: .touchUpInside)
        
        recordButton.snp.makeConstraints { (make) in
            make.top.equalTo(outerCircle.snp.bottom).offset(30)
            make.leading.equalTo(outerCircle)
            make.width.height.equalTo(40)
        }
        
        effectButton.snp.makeConstraints { (make) in
            make.top.equalTo(recordButton)
            make.trailing.equalTo(outerCircle)
            make.width.height.equalTo(40)
        }
    }
    
    
    func makeButton(imgName: String) -> UIButton {
        let button = UIButton()
        let img = UIImage(named: imgName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(img, for: .normal)
        button.tintColor = UIColor.white
        return button
    }
    
    @objc func changeEffectStatus() {
        self.effectEnabled = !self.effectEnabled
        let str = self.effectEnabled ? "You have enabled voice effect!" : "You have disabled voice effect!"
        let vc = UIAlertController(title: "Effect Status Changed", message: str, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func lockScreen() {
        let singingVC: SingingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singingVC") as! SingingViewController
        singingVC.setEffectEnabled(self.effectEnabled)
        self.present(singingVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
