//
//  WebsocketConnect.swift
//  MemuBar
//
//  Created by empsson on 16/1/24.
//  Copyright © 2016年 coin. All rights reserved.
//

import Foundation
import Starscream
import Reachability

//网络连接
var reach: Reachability!

// channel from loadfile.plist
var channel: Array<String> = []


class WebSocketConnect: WebSocketDelegate {
    
    
    
    let comSocket = WebSocket(url: NSURL(string: "wss://real.okcoin.com:10440/websocket/okcoinapi")!, protocols: ["chat"," superchat"])
    let cnSocket = WebSocket(url: NSURL(string: "wss://real.okcoin.cn:10440/websocket/okcoinapi")!, protocols: ["chat"," superchat"])
    var socket: WebSocket!
    
    

    var channelNumber = 0
    
    func connect() {
        comSocket.delegate = self
        comSocket.connect()
        
        cnSocket.delegate = self
        cnSocket.connect()
    }
    
    func disconnect() {
        comSocket.disconnect()
        cnSocket.disconnect()
    }
    
    
    func addChannel() {
        if channelNum < 2 {
            cnSocket.writeString("{'event':'addChannel','channel':'\(channel[channelNum])'}")
        }
        else {
            comSocket.writeString("{'event':'addChannel','channel':'\(channel[channelNum])'}")
        }
        channelNumber = channelNum
    }
    
    func removeChannel() {
        if channelNumber < 2 {
            cnSocket.writeString("{'event':'removeChannel','channel':'\(channel[channelNumber])'}")
        }
        else {
            comSocket.writeString("{'event':'removeChannel','channel':'\(channel[channelNumber])'}")
        }
    }
    
    func isConnectting() {
        if comSocket.isConnected == false {
            comSocket.connect()
        }
        if cnSocket.isConnected == false {
            cnSocket.connect()
        }
    }
    
    
    // MARK: Websocket Delegate Methods.
    
    var comWritePingnum = 0
    var cnWritePingnum = 0
    
    func iscomConnected() {
        let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(5.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.comSocket.writePing(NSData())
            self.iscomConnected()
            self.comWritePingnum = 1
        }
    }
    
    func iscnConnected() {
        let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(5.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.comSocket.writePing(NSData())
            self.iscnConnected()
            self.cnWritePingnum = 1
        }
    }
    
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
        
        addChannel()
        
        if comWritePingnum == 0 {
            iscomConnected()
        }
        if cnWritePingnum == 0 {
            iscnConnected()
        }
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            /* error:
            The operation couldn’t be completed. Socket is not connected
            The operation couldn’t be completed. (kCFErrorDomainCFNetwork error 2.)
            */
            if e.localizedDescription == "The operation couldn’t be completed. Socket is not connected" {
                print("连接断开，5秒后重新建立连接！")
            }
            else if e.localizedDescription == "The operation couldn’t be completed. (kCFErrorDomainCFNetwork error 2.)" {
                print("网络未连接！")
                return
            }
            else if e.localizedDescription == "connection closed by server" {
                print("连接已断开！")
                return
            }
        } else {
            print("未连接，5秒后重新建立连接！")
        }
        
        let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(5.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.isConnectting()
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        if text != "" {
            //print(text)
            if let messageArr: NSArray = try?NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments) as! NSArray {
                for arr in messageArr {
                    let channel: String = arr.valueForKey("channel") as! String
                    if let _ = arr.valueForKey("errorcode") {
                        
                    }
                    else if let _ = arr.valueForKey("") {
                        
                    }
                    else if let data: NSDictionary = arr.valueForKey("data") as? NSDictionary {
//                        print(data)
                        let dataDic = NSMutableDictionary()
                        dataDic.setValue(data, forKey: "text")
                        print(channel)
                        //注册通知
                        let notification = NSNotification(name: channel, object: nil, userInfo: dataDic as [NSObject:AnyObject])
                        //发送通知
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                    }
                }
            }
        }
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
}


