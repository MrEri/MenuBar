//
//  AppDelegate.swift
//  MemuBar
//
//  Created by empsson on 16/1/14.
//  Copyright © 2016年 coin. All rights reserved.
//

import Cocoa
import Foundation
import Starscream
import Reachability


var channelNum = 0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusBar = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    let statusMenu = NSMenu()
    
    /*
        public func startSpeaking(sender: AnyObject?)
     */
    
    var priceSpeak = NSTextView()
    var time: NSTimer?
    
    let pstyle = NSMutableParagraphStyle()
    var color: NSColor = NSColor()
    
    let spotBTCcn = NSMenuItem(title: "BTC现货cn", action: "item:", keyEquivalent: "")
    let spotLTCcn = NSMenuItem(title: "LTC现货cn", action: "item:", keyEquivalent: "")
    
    let spotBTCcom = NSMenuItem(title: "BTC现货com", action: "item:", keyEquivalent: "")
    let spotLTCcom = NSMenuItem(title: "LTC现货com", action: "item:", keyEquivalent: "")
    
    let futureBTCThisWeek = NSMenuItem(title: "BTC本周", action: "item:", keyEquivalent: "")
    let futureBTCNextWeek = NSMenuItem(title: "BTC次周", action: "item:", keyEquivalent: "")
    let futureBTCQuarter = NSMenuItem(title: "BTC季度", action: "item:", keyEquivalent: "")
    
    let futureLTCThisWeek = NSMenuItem(title: "LTC本周", action: "item:", keyEquivalent: "")
    let futureLTCNextWeek = NSMenuItem(title: "LTC次周", action: "item:", keyEquivalent: "")
    let futureLTCQuarter = NSMenuItem(title: "LTC季度", action: "item:", keyEquivalent: "")
    
    let quit = NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: "")
    
    
    var webSocketConnect = WebSocketConnect()
    
    let upPic = NSImage(named: "NSStatusAvailable")
    let downPic = NSImage(named: "NSStatusUnavailable")
    let pingPic = NSImage(named: "NSStatusNone")
    var price: Double = 0
    
    var itemTitle = "BTC现货cn"
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let diaryList: String = NSBundle.mainBundle().pathForResource("loadfile", ofType:"plist")!
        let data:NSMutableDictionary = NSMutableDictionary(contentsOfFile: diaryList)!
        channel = data.valueForKey("channelArr") as! Array<String>
        
        let colorLoad: String = data.valueForKey("color") as! String
        
        switch colorLoad {
        case "black":
            color = .blackColor()
        case "darkGray":
            color = .darkGrayColor()
        case "lightGray":
            color = .lightGrayColor()
        case "white":
            color = .whiteColor()
        case "gray":
            color = .grayColor()
        case "red":
            color = .redColor()
        case "green":
            color = .greenColor()
        case "blue":
            color = .blueColor()
        case "cyan":
            color = .cyanColor()
        case "yellow":
            color = .yellowColor()
        case "magenta":
            color = .magentaColor()
        case "orange":
            color = .orangeColor()
        case "purple":
            color = .purpleColor()
        case "brown":
            color = .brownColor()
        default:
            color = .whiteColor()
        }
        
        
        
        
        
        
        //接收网络连接状态通知
        reach = Reachability.reachabilityForInternetConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ReachabilityChanged:", name: "kReachabilityChangedNotification", object: nil)
        reach.startNotifier()
        
        webSocketConnect.connect()
        
        spotBTCcn.tag = 0
        spotLTCcn.tag = 1
        spotBTCcom.tag = 2
        spotLTCcom.tag = 3
        futureBTCThisWeek.tag = 4
        futureBTCNextWeek.tag = 5
        futureBTCQuarter.tag = 6
        futureLTCThisWeek.tag = 7
        futureLTCNextWeek.tag = 8
        futureLTCQuarter.tag = 9
        
        
        statusBar.menu = statusMenu
        statusBar.highlightMode = false
        statusBar.image = pingPic
        
        pstyle.alignment = .Center
        statusBar.attributedTitle = NSAttributedString(string: "Hello!", attributes: [ NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : pstyle ])
        
        
        
        statusMenu.addItem(spotBTCcn)
        statusMenu.addItem(spotLTCcn)
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        statusMenu.addItem(spotBTCcom)
        statusMenu.addItem(spotLTCcom)
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        statusMenu.addItem(futureBTCThisWeek)
        statusMenu.addItem(futureBTCNextWeek)
        statusMenu.addItem(futureBTCQuarter)
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        statusMenu.addItem(futureLTCThisWeek)
        statusMenu.addItem(futureLTCNextWeek)
        statusMenu.addItem(futureLTCQuarter)
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        statusMenu.addItem(quit)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Ticker:", name: channel[0], object: nil)
        
        time = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(AppDelegate.speaking(_:)), userInfo: nil, repeats: true)
    }
    
    func speaking(sender: NSTimer) {
        switch channelNum {
        case 0:
            self.priceSpeak.string! = "比特中国\(self.price)"
        case 1:
            self.priceSpeak.string! = "莱特中国\(self.price)"
        case 2:
            self.priceSpeak.string! = "比特国际\(self.price)"
        case 3:
            self.priceSpeak.string! = "莱特国际\(self.price)"
        case 4:
            self.priceSpeak.string! = "比特本周\(self.price)"
        case 5:
            self.priceSpeak.string! = "比特次周\(self.price)"
        case 6:
            self.priceSpeak.string! = "比特季度\(self.price)"
        case 7:
            self.priceSpeak.string! = "莱特本周\(self.price)"
        case 8:
            self.priceSpeak.string! = "莱特次周\(self.price)"
        case 9:
            self.priceSpeak.string! = "莱特季度\(self.price)"
        default: break
        }
        self.priceSpeak.startSpeaking(nil)
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func item(sender: NSMenuItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: channel[channelNum], object: nil)
        channelNum = sender.tag
        itemTitle = sender.title
        price = 0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Ticker:", name: channel[channelNum], object: nil)
        webSocketConnect.removeChannel()
        webSocketConnect.addChannel()
        
    }
    
    func Ticker(info: NSUserNotification) {
        var priceType = ""
        if channelNum < 2 {
            priceType = "¥"
        }
        else {
            priceType = "$"
        }
        
        if let okTicker = info.userInfo!["text"] as? NSDictionary {
            
            if let _ = okTicker.valueForKey("success") as? String {
                
            }
            else {
                let last = NSString(string: okTicker.valueForKey("last") as! String)
                let lastPrice = last.doubleValue
                
                if price == 0 || price == lastPrice {
                    statusBar.image = pingPic
                }
                else if price > lastPrice {
                    statusBar.image = downPic
                }
                else {
                    statusBar.image = upPic
                }
                
                price = lastPrice
                
                pstyle.alignment = .Center
                statusBar.attributedTitle = NSAttributedString(string: "\(itemTitle)\(priceType):\(last)", attributes: [ NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : pstyle ])
            }
        }
    }
    
    //检测网络连接
    func ReachabilityChanged(note: NSUserNotification) {
        
        if reach.isReachable() == true {
            webSocketConnect.connect()
            print("WebSocketConnect: 网络已连接！")
        }
    }
    
}




