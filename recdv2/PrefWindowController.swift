//
//  PrefWindowController.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/01.
//  Copyright © 2016-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

@objcMembers
class PreferencesController: NSViewController {
    
    /* ======================================================================================== */
    // MARK: - IBOutlet
    /* ======================================================================================== */
    
    @IBOutlet weak var devMuxedArrayController: NSArrayController!
    @IBOutlet weak var devVideoArrayController: NSArrayController!
    @IBOutlet weak var devAudioArrayController: NSArrayController!
    
    @IBOutlet weak var prefWindow: NSWindow!
    @IBOutlet weak var appDelegate: AppDelegate!
    
    /* ======================================================================================== */
    // MARK: - IBAction
    /* ======================================================================================== */
    
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
    
    @IBAction func resetCompressSettings(_ sender: AnyObject) {
        // Post notification
        let notification = Notification(name: .loadCompressionSettingsNotificationKey,
                                        object:self,
                                        userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    /* ======================================================================================== */
    // MARK: - Misc support
    /* ======================================================================================== */
    
    private func setup() {
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
