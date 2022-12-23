//
//  AppDelegate+Signal.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/22.
//  Copyright © 2022 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

extension AppDelegate {

    /* ======================================================================================== */
    // MARK: - Signal Handler
    /* ======================================================================================== */

    func startActivity() {
        Swift.print("\(#file) \(#line) \(#function)")
        let proc : ProcessInfo = ProcessInfo.processInfo
        let opt : ProcessInfo.ActivityOptions =
            [.automaticTerminationDisabled, .userInitiated, .latencyCritical]
        activityToken = proc.beginActivity(options: opt,
                                           reason: "recdv2 is running")
    }
    
    func endActivity() {
        Swift.print("\(#file) \(#line) \(#function)")
        if let activityToken = activityToken {
            let proc : ProcessInfo = ProcessInfo.processInfo
            proc.endActivity(activityToken)
        }
    }
    
    func installSignalHandler() {
        signal(SIGTERM, SIG_IGN)
        signal(SIGUSR1, SIG_IGN)
        signal(SIGUSR2, SIG_IGN)
        
        srcSIGTERM = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        srcSIGTERM?.setEventHandler {
            print("\(#file) \(#line) \(#function)")
            DispatchQueue.main.async {
                print("\(#file) \(#line) \(#function)")
                NSApp.terminate(self)
            }
        }
        srcSIGTERM?.resume()
        
        srcSIGUSR1 = DispatchSource.makeSignalSource(signal: SIGUSR1, queue: .main)
        srcSIGUSR1?.setEventHandler {
            print("\(#file) \(#line) \(#function)")
            DispatchQueue.main.async {
                print("\(#file) \(#line) \(#function)")
                self.targetPath = nil       // Use autogenerated movie path
                self.startRecording(for:0)
            }
        }
        srcSIGUSR1?.resume()
        
        srcSIGUSR2 = DispatchSource.makeSignalSource(signal: SIGUSR2, queue: .main)
        srcSIGUSR2?.setEventHandler {
            print("\(#file) \(#line) \(#function)")
            DispatchQueue.main.async {
                print("\(#file) \(#line) \(#function)")
                self.stopRecording()
            }
        }
        srcSIGUSR2?.resume()
    }
    
}
