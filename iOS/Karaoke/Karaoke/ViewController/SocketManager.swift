//
//  SocketManager.swift
//  Karaoke
//
//  Created by 安哲宏 on 4/24/18.
//  Copyright © 2018 cmu.edu. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SocketManager: NSObject, GCDAsyncSocketDelegate {
    static var _socket: GCDAsyncSocket?
    
    class func sharedInstance() -> GCDAsyncSocket {
        if _socket == nil {
            _socket = GCDAsyncSocket()
        }
        return _socket!
    }
    
    class func sendCmd(cmd: String) {
        let data = cmd.data(using: String.Encoding.utf8)
        
        let socket = SocketManager.sharedInstance()
        socket.write(data!, withTimeout: -1, tag: 110)
    }
}
