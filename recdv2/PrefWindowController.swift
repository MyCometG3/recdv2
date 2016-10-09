//
//  PrefWindowController.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/01.
//  Copyright © 2016年 MyCometG3. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the <MyCometG3> nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <MyCometG3> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Cocoa

@objc(PreferencesController)
class PreferencesController: NSViewController {
    @IBOutlet weak var devMuxedArrayController: NSArrayController!
    @IBOutlet weak var devVideoArrayController: NSArrayController!
    @IBOutlet weak var devAudioArrayController: NSArrayController!
    
    @IBOutlet weak var prefWindow: NSWindow!
    @IBOutlet weak var appDelegate: AppDelegate!
    
    @IBAction func showPreferences(_ sender: AnyObject) {
        prefWindow.makeKeyAndOrderFront(self)
        setup()
    }
    
    @IBAction func restartSession(_ sender: AnyObject) {
        // Prepare userInfo
        let muxed = (devMuxedArrayController.selection as! NSObject).value(forKey: Keys.uniqueID)
        let video = (devVideoArrayController.selection as! NSObject).value(forKey: Keys.uniqueID)
        let audio = (devAudioArrayController.selection as! NSObject).value(forKey: Keys.uniqueID)
        let userInfo : [String:Any] = [
            Keys.uniqueIDMuxed: muxed ?? NSNull(),
            Keys.uniqueIDVideo: video ?? NSNull(),
            Keys.uniqueIDAudio: audio ?? NSNull(),
            ]
        
        // Post notification with userInfo
        let notification = Notification(name: .restartSessionNotificationKey,
                                        object: self,
                                        userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    func setup() {
        // Populate Popup Button contents
        if let manager = appDelegate.manager {
            devMuxedArrayController.content = NSMutableArray(array: manager.devicesMuxed())
            devVideoArrayController.content = NSMutableArray(array: manager.devicesVideo())
            devAudioArrayController.content = NSMutableArray(array: manager.devicesAudio())
            
            if let muxed = manager.currentDeviceIDVideo {
                for item in manager.devicesMuxed() {
                    guard let itemDict = item as? Dictionary<String, Any> else {continue}
                    guard let itemID = itemDict[Keys.uniqueID] as? String else {continue}
                    if itemID == muxed {
                        // print(item.valueForKey("localizedName") as! String)
                        devMuxedArrayController.setSelectedObjects([item])
                        break
                    }
                }
            }
            
            if let video = manager.currentDeviceIDVideo {
                for item in manager.devicesVideo() {
                    guard let itemDict = item as? Dictionary<String, Any> else {continue}
                    guard let itemID = itemDict[Keys.uniqueID] as? String else {continue}
                    if itemID == video {
                        // print(item.valueForKey("localizedName") as! String)
                        devVideoArrayController.setSelectedObjects([item])
                        break
                    }
                }
            }
            
            if let audio = manager.currentDeviceIDAudio {
                for item in manager.devicesAudio() {
                    guard let itemDict = item as? Dictionary<String, Any> else {continue}
                    guard let itemID = itemDict[Keys.uniqueID] as? String else {continue}
                    if itemID == audio {
                        // print(item.valueForKey("localizedName") as! String)
                        devAudioArrayController.setSelectedObjects([item])
                        break
                    }
                }
            }
        }
    }
}
