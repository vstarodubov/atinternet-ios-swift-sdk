/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  RichMedia.swift
//  Tracker
//

import UIKit

public class RichMedia : BusinessObject {
    
    /// Rich media broadcast type
    public enum BroadcastMode: String {
        case Clip = "clip"
        case Live = "live"
    }
    
    /// Rich media hit status
    public enum Action: String {
        case Play = "play"
        case Pause = "pause"
        case Stop = "stop"
        case Move = "move"
        case Refresh = "refresh"
    }
    
    /// Player instance
    var player: MediaPlayer
    
    /// Refresh timer
    var timer: NSTimer?
    
    /// Media is buffering
    public var isBuffering: Bool?
    
    /// Media is embedded in app
    public var isEmbedded: Bool?
    
    /// Media is live or clip
    var broadcastMode: BroadcastMode = BroadcastMode.Clip
    
    /// Media name
    public var name: String = ""
    
    /// First chapter
    public var chapter1: String?
    
    /// Second chapter
    public var chapter2: String?
    
    /// Third chapter
    public var chapter3: String?
    
    /// Level 2
    public var level2: Int?
    
    /// Refresh Duration
    var refreshDuration: Int = 5
    
    /// Action
    public var action: Action = Action.Play
    
    /// Web domain 
    public var webdomain: String?
   
    init(player: MediaPlayer) {
        self.player = player
        
        super.init(tracker: player.tracker)
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        self.tracker.setParam("p", value: buildMediaName(), options: encodingOption)
        
        self.tracker.setParam("plyr", value: player.playerId)
        
        self.tracker.setParam("m6", value: broadcastMode.rawValue)
        
        self.tracker.setParam("a", value: action.rawValue)
        
        if let optIsEmbedded = self.isEmbedded {
            self.tracker.setParam("m5", value: optIsEmbedded ? "ext" : "int")
        }
        
        if let optLevel2 = self.level2 {
            self.tracker.setParam("s2", value: optLevel2)
        }
        
        if(action == Action.Play) {
            if let optIsBuffering = self.isBuffering {
                self.tracker.setParam("buf", value: optIsBuffering ? 1 : 0)
            }
            
            if let optIsEmbedded = self.isEmbedded {
                if (optIsEmbedded) {
                    if let optWebDomain = self.webdomain {
                        self.tracker.setParam("m9", value: optWebDomain)
                    }
                } else {
                    if TechnicalContext.screenName != "" {
                        self.tracker.setParam("prich", value: TechnicalContext.screenName, options: encodingOption)
                    }
                    
                    if TechnicalContext.level2 > 0 {
                        self.tracker.setParam("s2rich", value: TechnicalContext.level2)
                    }
                }
            }
            
        }
    }
    
    /// Media name building
    func buildMediaName() -> String {
        var mediaName = chapter1 == nil ? "" : chapter1! + "::"
        mediaName = chapter2 ==  nil ? mediaName : mediaName + chapter2! + "::"
        mediaName = chapter3 ==  nil ? mediaName : mediaName + chapter3! + "::"
        mediaName += name
        
        return mediaName
    }
    
    /**
    Send hit when media is played
    Refresh is enabled with default duration
    */
    public func sendPlay() {
        self.action = Action.Play
        
        self.tracker.dispatcher.dispatch([self])
        
        self.initRefresh()
    }
    
    /**
    Send hit when media is played
    Refresh is enabled if resfreshDuration is not equal to 0
    - parameter resfreshDuration: duration between refresh hits
    */
    public func sendPlay(refreshDuration: Int) {
        
        self.action = Action.Play
        
        self.tracker.dispatcher.dispatch([self])
        
        if (refreshDuration != 0) {
            if (refreshDuration > 5) {
                self.refreshDuration = refreshDuration
            }
            self.initRefresh()
        }
        
    }
    
    /**
    Send hit when media is paused
    */
    public func sendPause(){
        
        if let timer = self.timer {
            if timer.valid {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        self.action = Action.Pause
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send hit when media is stopped
    */
    public func sendStop() {
        
        if let timer = self.timer {
            if timer.valid {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        self.action = Action.Stop
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    /**
    Send hit when media cursor position is moved
    */
    public func sendMove() {
        self.action  = Action.Move
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Start the refresh timer
    func initRefresh() {
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(
                NSTimeInterval(self.refreshDuration), target: self, selector: Selector("sendRefresh"), userInfo: nil, repeats: true)
        }
        
    }
    
    /// Medthod called on the timer tick
    @objc func sendRefresh() {
        self.action = Action.Refresh
        
        self.tracker.dispatcher.dispatch([self])
    }
    
}
