//
//  AppDelegate+Scripting.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/22.
//  Copyright © 2022-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

@objc
extension NSApplication {
    
    /* ======================================================================================== */
    // MARK: - Cocoa scripting support; for NSApplication extension
    /* ======================================================================================== */
    
    func handleRestartSessionCommand(_ command: CustomCommand) {
        // print("\(#file) \(#line) \(#function)")
        
        // Post notification without userInfo
        let notification = Notification(name: .RDV2RestartSessionCommandKey,
                                        object: self,
                                        userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func handleStopRecordingCommand(_ command: CustomCommand) {
        // print("\(#file) \(#line) \(#function)")
        
        // Post notification without userInfo
        let notification = Notification(name: .RDV2StopRecordingCommandKey,
                                        object: self,
                                        userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func handleStartRecordingCommand(_ command: CustomCommand) {
        // print("\(#file) \(#line) \(#function)")
        
        let fileURL: URL? = command.evaluatedArguments?[Keys.fileURL] as? URL
        let maxSeconds: Float? = command.evaluatedArguments?[Keys.maxSeconds] as? Float
        let autoQuit: Bool? = command.evaluatedArguments?[Keys.autoQuit] as? Bool
        
        // Post notification with userInfo
        let userInfo : [String:Any] = [
            Keys.fileURL : fileURL as Any,
            Keys.maxSeconds : maxSeconds as Any,
            Keys.autoQuit : autoQuit as Any
        ]
        
        let notification = Notification(name: .RDV2StartRecordingCommandKey,
                                        object: self,
                                        userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
}

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for NSScriptCommand subclass
/* ======================================================================================== */

@objcMembers
class CustomCommand: NSScriptCommand {
    
    override func performDefaultImplementation() -> Any? {
        // print("\(#file) \(#line) \(#function)")
        
        // Unhandled command detected
        let errorMsg = "ERROR: CustomCommand: Internal error is detected."
        
        print(errorMsg)
        print("- Command description: \(self.commandDescription)")
        if let directParameter = self.directParameter {
            print("- Direct parameter: \(directParameter)")
        }
        if let arguments = self.evaluatedArguments {
            print("- Evaluated arguments: \(arguments)")
        }
        
        return errorMsg
    }
    
}

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for AppDelegate extension
/* ======================================================================================== */

extension AppDelegate {
    
    func checkSupportedScriptingKey(_ key: String) -> Bool {
        // print("\(#file) \(#line) \(#function)")
        
        let supportedParameter = [Keys.sessionItem,
                                  Keys.recordingItem,
                                  Keys.folderURL,
                                  Keys.useVideoPreview,
                                  Keys.useAudioPreview]
        if supportedParameter.contains(key) {
            // print("- delegate handles: \(key)")
            return true
        } else {
            // print("- delegate do not handles: \(key)")
            return false
        }
    }
    
    var sessionItem: RDV2Session? {
        get { return _sessionItem }
    }
    
    var recordingItem: RDV2Recording? {
        get { return _recordingItem }
    }
    
    var folderURL: URL? {
        get { return movieFolder() }
        set { self.defaults.set(newValue, forKey: Keys.movieFolder) }
    }
    
    var useVideoPreview: Bool {
        get { return !defaults.bool(forKey: Keys.showAlternate) }
        set {
            defaults.set(!newValue, forKey: Keys.showAlternate)
            setScale(-1)                        // Update Popup Menu Selection
        }
    }
    
    var useAudioPreview: Bool {
        get { return !defaults.bool(forKey: Keys.forceMute) }
        set {
            defaults.set(!newValue, forKey: Keys.forceMute)
            setVolume(-1)                       // Update Popup Menu Selection
        }
    }
    
    // MARK: -
    
    func registerObserverForScriptingSupport() {
        // print("\(#file) \(#line) \(#function)")
        
        // Register notification observer for Cocoa scripting support
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRestartSessionNotification),
                                       name: .RDV2RestartSessionCommandKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleStartRecordingNotification),
                                       name: .RDV2StartRecordingCommandKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleStopRecordingNotification),
                                       name: .RDV2StopRecordingCommandKey,
                                       object: nil)
    }
    
    func handleRestartSessionNotification(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Synchronous operation for Script support
        restartSession(notification)
    }
    
    func handleStartRecordingNotification(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        //
        targetPath = nil
        var length : Int = 0
        
        if let userInfo = notification.userInfo {
            if let item = userInfo[Keys.fileURL] as? URL {
                targetPath = item.path
            }
            if let item = userInfo[Keys.maxSeconds] as? Float {
                length = Int(item)
            }
            if let item = userInfo[Keys.autoQuit] as? Bool {
                defaults.set(item, forKey: Keys.autoQuit)
            }
        }
        
        // Synchronous operation for Script support
        startRecording(for:length)
    }
    
    func handleStopRecordingNotification(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Synchronous operation for Script support
        stopRecording()
    }
    
}
