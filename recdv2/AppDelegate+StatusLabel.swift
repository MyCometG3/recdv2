//
//  AppDelegate+StatusLabel.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/23.
//  Copyright © 2022 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

extension AppDelegate {
    
    /* ======================================================================================== */
    // MARK: - Status label support
    /* ======================================================================================== */
    
    func startUpdateStatus() {
        // print("\(#file) \(#line) \(#function)")
        
        // setup status update timer
        if updateTimer == nil {
            updateTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                               target: self,
                                               selector: #selector(updateStatusDefault),
                                               userInfo: nil,
                                               repeats: true)
        }
    }
    
    func stopUpdateStatus() {
        // print("\(#file) \(#line) \(#function)")
        
        // discard status update timer
        if let updateTimer = updateTimer {
            updateTimer.invalidate()
            self.updateTimer = nil
        }
        
        // turn off status label
        defaults.set(false, forKey: Keys.statusVisible)
        defaults.setValue("", forKey: Keys.statusString)
    }
    
    func updateStatusDefault() {
        // print("\(#file) \(#line) \(#function)")
        
        // Show default status string
        updateStatus(nil)
        
        // Try update preview connection enabled state as is
        checkOnActiveSpace()
        
        // Dock Icon Animation
        if let manager = manager , manager.isRecording() {
            // Perform AppIcon Animation
            iconActiveState = !iconActiveState
            NSApp.applicationIconImage = iconActiveState ? iconActive : iconInactive
        } else {
            // Stop AppIcon Animation
            if iconActiveState {
                iconActiveState = false
                NSApp.applicationIconImage = iconInactive
            }
        }
    }
    
    private func updateStatus(_ status: String?) {
        // print("\(#file) \(#line) \(#function)")
        
        if let status = status , status.count > 0 {
            // Stop updateStatus Timer
            stopUpdateStatus()
            
            // Show requested status string
            defaults.set(true, forKey: Keys.statusVisible)
            defaults.setValue(status, forKey: Keys.statusString)
        } else {
            // Start updateStatus Timer
            startUpdateStatus()
            
            // Show auto-generated status string
            var visible = false
            var status = ""
            let showAlternate = defaults.bool(forKey: Keys.showAlternate)
            let forceMute = defaults.bool(forKey: Keys.forceMute)
            
            if let manager = manager , manager.isRecording() {
                // Recording now
                visible = true
                status = "Recording..."
                
                if let stopTimer = stopTimer , limitFlag {
                    let interval: TimeInterval = stopTimer.fireDate.timeIntervalSince(Date())
                    if interval > 120 {
                        status = "Recording remains \(Int(interval/60)) minute(s)..."
                    } else {
                        status = "Recording remains \(Int(interval)) second(s)..."
                    }
                    
                    let autoQuit = defaults.bool(forKey: Keys.autoQuit)
                    if autoQuit {
                        status += " (AutoQuit)"
                    }
                }
            } else {
                // Show when preview is disabled
                if showAlternate || forceMute {
                    visible = true
                    status = " preview is disabled."
                    if showAlternate && forceMute {
                        status = "Video/Audio" + status
                    } else if showAlternate {
                        status = "Video" + status
                    } else if forceMute {
                        status = "Audio" + status
                    }
                }
            }
            
            // Update status string
            defaults.set(visible, forKey: Keys.statusVisible)
            defaults.setValue(status, forKey: Keys.statusString)
        }
    }
    
}
