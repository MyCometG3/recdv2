//
//  RDV2Session.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/08/20.
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
            return defaults.set(muxed, forKey: Keys.useMuxed)
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
        let notification = Notification(name: .RDV2SessionChangedKey,
                                        object: [Keys.newSessionData: self])
        notificationCenter.post(notification)
    }
}
