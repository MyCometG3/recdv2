//
//  RDV2Session.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/08/20.
//  Copyright © 2016-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for Script class RDV2Session
/* ======================================================================================== */

@objcMembers
class RDV2Session: NSObject {
    /* ============================================================================== */
    
    var name: String = "current session"
    var uniqueID: String = UUID().uuidString
    
    override var objectSpecifier: NSScriptObjectSpecifier? {
        let appDescription = NSApp.classDescription as! NSScriptClassDescription
        //let specifier = NSUniqueIDSpecifier(containerClassDescription: appDescription,
        //                                    containerSpecifier: nil,
        //                                    key: "sessionItem",
        //                                    uniqueID: self.uniqueID)
        //let specifier = NSNameSpecifier(containerClassDescription: appDescription,
        //                                containerSpecifier: nil,
        //                                key: "sessionItem",
        //                                name: self.name)
        let specifier = NSPropertySpecifier(containerClassDescription: appDescription,
                                            containerSpecifier: nil,
                                            key: "sessionItem")
        return specifier
    }
    
    /* ============================================================================== */
    
    var running: Bool {
        get {
            if let appDelegate = appDelegate, let manager = appDelegate.manager {
                return manager.isReady()
            }
            return false
        }
    }
    
    var muxed: Bool {
        get {
            return defaults.bool(forKey: Keys.useMuxed)
        }
        set {
            return defaults.set(newValue, forKey: Keys.useMuxed)
        }
    }
    
    var muxedSrcID: String? {
        get {
            if let item = defaults.value(forKey: Keys.uniqueIDMuxed) as? String {
                return item
            }
            return nil
        }
        set {
            guard let deviceID = newValue else { return }
            for item in muxedSrcAvailable {
                guard let obj = item as? Dictionary<String, Any> else { continue }
                guard let objUniqueID = obj[Keys.uniqueID] as? String else { continue }
                if objUniqueID == deviceID {
                    defaults.setValue(deviceID, forKey: Keys.uniqueIDMuxed)
                    return
                }
            }
            print("ERROR: No such device ID is available")
        }
    }
    
    var videoSrcID: String? {
        get {
            if let item = defaults.value(forKey: Keys.uniqueIDVideo) as? String {
                return item
            }
            return nil
        }
        set {
            guard let deviceID = newValue else { return }
            for item in videoSrcAvailable {
                guard let obj = item as? Dictionary<String, Any> else { continue }
                guard let objUniqueID = obj[Keys.uniqueID] as? String else { continue }
                if objUniqueID == deviceID {
                    defaults.setValue(deviceID, forKey: Keys.uniqueIDVideo)
                    return
                }
            }
            print("ERROR: No such device ID is available")
        }
    }
    
    var audioSrcID: String? {
        get {
            if let item = defaults.value(forKey: Keys.uniqueIDAudio) as? String {
                return item
            }
            return nil
        }
        set {
            guard let deviceID = newValue else { return }
            for item in audioSrcAvailable {
                guard let obj = item as? Dictionary<String, Any> else { continue }
                guard let objUniqueID = obj[Keys.uniqueID] as? String else { continue }
                if objUniqueID == deviceID {
                    defaults.setValue(deviceID, forKey: Keys.uniqueIDAudio)
                    return
                }
            }
            print("ERROR: No such device ID is available")
        }
    }
    
    var muxedSrcAvailable: [Any] {
        get {
            var deviceInfoArray : [Any] = []
            if let appDelegate = appDelegate, let manager = appDelegate.manager {
                for item in manager.devicesMuxed() {
                    if let newItem = RDV2DeviceInfoMuxed(from: item) {
                        deviceInfoArray.append(newItem)
                        newItem.contDescription = (self.classDescription as! NSScriptClassDescription)
                        newItem.contSpecifier = self.objectSpecifier
                        newItem.contKey = "muxedSrcAvailable"
                    }
                }
            }
            return deviceInfoArray
        }
    }
    
    var videoSrcAvailable: [Any] {
        get {
            var deviceInfoArray : [Any] = []
            if let appDelegate = appDelegate, let manager = appDelegate.manager {
                for item in manager.devicesVideo() {
                    if let newItem = RDV2DeviceInfoVideo(from: item) {
                        deviceInfoArray.append(newItem)
                        newItem.contDescription = (self.classDescription as! NSScriptClassDescription)
                        newItem.contSpecifier = self.objectSpecifier
                        newItem.contKey = "videoSrcAvailable"
                    }
                }
            }
            return deviceInfoArray
        }
    }
    
    var audioSrcAvailable: [Any] {
        get {
            var deviceInfoArray : [Any] = []
            if let appDelegate = appDelegate, let manager = appDelegate.manager {
                for item in manager.devicesAudio() {
                    if let newItem = RDV2DeviceInfoAudio(from: item) {
                        deviceInfoArray.append(newItem)
                        newItem.contDescription = (self.classDescription as! NSScriptClassDescription)
                        newItem.contSpecifier = self.objectSpecifier
                        newItem.contKey = "audioSrcAvailable"
                    }
                }
            }
            return deviceInfoArray
        }
    }
    
    /* ============================================================================== */
    
    lazy var defaults = UserDefaults.standard
    lazy var notificationCenter = NotificationCenter.default
    var appDelegate : AppDelegate? = nil
    
    override init() {
        super.init()
        appDelegate = NSApp.delegate as? AppDelegate
    }
    
    func postNotificationOfChanges() {
        let notification = Notification(name: .RDV2SessionStateChangedKey,
                                        object: [Keys.newSessionData: self])
        notificationCenter.post(notification)
    }
}
