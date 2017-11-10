//
//  RDV2Recording.swift
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
// MARK: - Cocoa scripting support; for Script class RDV2Recording
/* ======================================================================================== */

@objcMembers
class RDV2Recording: NSObject {
    /* ============================================================================== */
    
    var name: String = "current recording"
    var uniqueID: String = UUID().uuidString
    
    override var objectSpecifier: NSScriptObjectSpecifier? {
        let appDescription = NSApp.classDescription as! NSScriptClassDescription
        let specifier = NSUniqueIDSpecifier(containerClassDescription: appDescription,
                                            containerSpecifier: nil,
                                            key: self.name,
                                            uniqueID: self.uniqueID)
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
                                       selector: #selector(handleStartRecording),
                                       name: .recordingStartedNotificationKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleStopRecording),
                                       name: .recordingStoppedNotificationKey,
                                       object: nil)
    }
    
    func postNotificationOfChanges() {
        let notification = Notification(name: .RDV2RecordingChangedKey,
                                        object: [Keys.newRecordingData: self])
        notificationCenter.post(notification)
    }
    
    func handleStartRecording(_ notification: Notification) {
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
    
    func handleStopRecording(_ notification: Notification) {
        endDate = Date()
        running = false
    }
}
