//
//  RDV2Recording.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/08/20.
//  Copyright © 2016-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for Script class RDV2Recording
/* ======================================================================================== */

@objcMembers
class RDV2Recording: NSObject {
    /* ============================================================================== */
    
    var name: String = "current recording"
    var uniqueID: String = UUID().uuidString
    
    override var objectSpecifier: NSScriptObjectSpecifier? {
        let appDescription = NSApp.classDescription as! NSScriptClassDescription
        //let specifier = NSUniqueIDSpecifier(containerClassDescription: appDescription,
        //                                    containerSpecifier: nil,
        //                                    key: "recordingItem",
        //                                    uniqueID: self.uniqueID)
        //let specifier = NSNameSpecifier(containerClassDescription: appDescription,
        //                                containerSpecifier: nil,
        //                                key: "recordingItem",
        //                                name: self.name)
        let specifier = NSPropertySpecifier(containerClassDescription: appDescription,
                                            containerSpecifier: nil,
                                            key: "recordingItem")
        return specifier
    }
    
    /* ============================================================================== */
    
    var running: Bool = false {
        didSet { postNotificationOfChanges() }
    }
    
    var fileURL: URL? = nil
    var startDate: Date? = nil
    var endDate: Date? = nil
    var durationInSec: NSNumber? {
        get {
            if let dateFrom = startDate {
                let dateTo = endDate ?? Date()
                let elapsed = dateTo.timeIntervalSince(dateFrom)
                return NSNumber(value: elapsed as Double)
            }
            return nil
        }
    }
    
    /* ============================================================================== */
    
    lazy var defaults = UserDefaults.standard
    lazy var notificationCenter = NotificationCenter.default
    
    override init() {
        super.init()
        
        // Register notification observer for Scripting support
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRecordingStartedNotification),
                                       name: .recordingStartedNotificationKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRecordingStoppedNotification),
                                       name: .recordingStoppedNotificationKey,
                                       object: nil)
    }
    
    func postNotificationOfChanges() {
        let notification = Notification(name: .RDV2RecordingStateChangedKey,
                                        object: [Keys.newRecordingData: self])
        notificationCenter.post(notification)
    }
    
    func handleRecordingStartedNotification(_ notification: Notification) {
        fileURL = nil
        if let userInfo = notification.userInfo {
            if let item = userInfo[Keys.fileURL] as? URL {
                fileURL = item
            }
        }
        
        startDate = Date()
        endDate = nil
        running = true
    }
    
    func handleRecordingStoppedNotification(_ notification: Notification) {
        endDate = Date()
        running = false
    }
}
