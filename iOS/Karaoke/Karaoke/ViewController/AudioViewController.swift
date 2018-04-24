//
//  AudioViewController.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/23/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import UIKit

class AudioViewController: UIViewController, MCAudioInputQueueDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    var started = false
    
    func inputQueue(_ inputQueue: MCAudioInputQueue!, inputData data: Data!, numberOfPackets: UInt32) {
        if (data != nil) {
            _data.append(data)
        }
        inputQueue.updateMeters()
        
        print("channel 0 averagePower = %lf, peakPower")
        
        var duration: Double = Double(_data.length) / (Double(recorder.bufferSize) * Double(recorder.bufferDuration))
        DispatchQueue.main.async {
            var durationStr = "duration = \(duration)"
            self.durationLabel.text = durationStr
        }
        
    }
    
    func inputQueue(_ inputQueue: MCAudioInputQueue!, errorOccur error: Error!) {
        stopRecord()
    }
    
    
    var format: AudioStreamBasicDescription!
    var recorder: MCAudioInputQueue!
    
    var _data: NSMutableData!
    var player: AVAudioPlayer!
    
    let bufferDuration: TimeInterval = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        commonInit()
    }
    
    func commonInit() {
        format = AudioStreamBasicDescription()
        format.mFormatID = kAudioFormatLinearPCM
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger
        format.mBitsPerChannel = 16
        format.mChannelsPerFrame = 2
        format.mBytesPerPacket = (format.mBitsPerChannel / 8)
        format.mBytesPerFrame = (format.mBitsPerChannel / 8)
        format.mFramesPerPacket = 1
        format.mSampleRate = 8000.0
        
        player = AVAudioPlayer()
//        do {
//            try player = AVAudioPlayer(pcmData: _data as Data?, pcmFormat: format)
//        } catch let err {
//            print(err)
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(interrupted), name: NSNotification.Name(rawValue: AVAudioSessionInterruptionTypeKey), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(interrupted), name: NSNotification.Name(rawValue: AVAudioSessionRouteChangeReasonKey), object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
    
    func startRecord() {
        if player != nil {
            player.stop()
        }
        
        started = true
        
        _data = NSMutableData()
        recorder = MCAudioInputQueue(format: format, bufferDuration: bufferDuration, delegate: self)
        recorder.meteringEnabled = true
        recorder.start()
    }
    
    func stopRecord() {
        if !started || recorder == nil {
            return
        }
        
        started = false
        
        recorder.stop()
        recorder = nil
        
    }
    
    func play() {
        player.stop()
        do {
            try player = AVAudioPlayer(pcmData: _data as Data?, pcmFormat: format)
        } catch let err {
            print(err)
        }
        
        player.play()
    }
    
    @objc func interrupted(notification: Notification) {
        print("interrupted")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        if started {
            stopRecord()
        } else {
            startRecord()
        }
    }
    
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        self.play()
    }
    
}
