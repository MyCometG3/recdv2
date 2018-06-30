//
//  AppDelegate.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/08/14.
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
import AVFoundation
import AVCaptureManager

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for NSApplication extension
/* ======================================================================================== */

@objc
extension NSApplication {
    func handleRestartSession(_ command: NSScriptCommand) {
        // print("\(#file) \(#line) \(#function)")
        
        // Post notification without userInfo
        let notification = Notification(name: .handleRestartSessionKey,
                                        object: self,
                                        userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func handleStopRecord(_ command: NSScriptCommand) {
        // print("\(#file) \(#line) \(#function)")
        
        // Post notification without userInfo
        let notification = Notification(name: .handleStopRecordingKey,
                                        object: self,
                                        userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    func handleStartRecord(_ command: NSScriptCommand) {
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
        
        let notification = Notification(name: .handleStartRecordingKey,
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
// MARK: - Cocoa scripting support; for NSApplication delegate
/* ======================================================================================== */

@NSApplicationMain
@objcMembers
class AppDelegate: NSObject, NSApplicationDelegate, CALayerDelegate, CALayoutManager, NSWindowDelegate {
    override func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
        // print("\(#file) \(#line) \(#function)")
        
        let supportedParameter = [Keys.sessionItem, Keys.recordingItem, Keys.folderURL,
                                  Keys.useVideoPreview, Keys.useAudioPreview]
        if supportedParameter.contains(key) {
            // print("- delegate handles: \(key)")
            return true
        } else {
            // print("- delegate do not handles: \(key)")
            return false
        }
    }
    
    lazy var _sessionItem: RDV2Session = RDV2Session()
    var sessionItem: RDV2Session? {
        get { return _sessionItem }
    }
    
    lazy var _recordingItem: RDV2Recording = RDV2Recording()
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
    
    func registerObserverForScriptingSupport() {
        // print("\(#file) \(#line) \(#function)")
        
        // Register notification observer for Cocoa scripting support
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRestartSession),
                                       name: .handleRestartSessionKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleStartRecording),
                                       name: .handleStartRecordingKey,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleStopRecording),
                                       name: .handleStopRecordingKey,
                                       object: nil)
    }
    
    func handleRestartSession(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Synchronous operation for Script support
        restartSession(notification)
    }
    
    func handleStartRecording(_ notification: Notification) {
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
    
    func handleStopRecording(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Synchronous operation for Script support
        stopRecording()
    }
    
    /* ======================================================================================== */
    // MARK: - Signal Handler
    /* ======================================================================================== */
    
    var activityToken : NSObjectProtocol? = nil
    
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
    
    var srcSIGTERM : DispatchSourceSignal? = nil
    var srcSIGUSR1 : DispatchSourceSignal? = nil
    var srcSIGUSR2 : DispatchSourceSignal? = nil
    
    private func installSignalHandler() {
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
    
    /* ======================================================================================== */
    // MARK: - NSApplicationDelegate protocol
    /* ======================================================================================== */
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Register notification observer for Cocoa scripting support
        registerObserverForScriptingSupport()
        
        // Register notification observer for Restarting AVCaptureSession
        notificationCenter.addObserver(self,
                                       selector: #selector(restartSession),
                                       name: .restartSessionNotificationKey,
                                       object: nil)
        
        // Register defaults defautl values
        var keyValues:[String:Any] = [:]
        keyValues[Keys.aspectRatio] = 40033    // 40:33 for DV-NTSC
        keyValues[Keys.scale] = 100            // Video preview scale 100%
        keyValues[Keys.volume] = 100           // Audio preview volume 100%
        keyValues[Keys.volumeTag] = -1         // -1:Vol: now%
        keyValues[Keys.scaleTag] = -1          // -1:Scale: now%
        
        keyValues[Keys.videoFormat] = 0        // 0:DeviceNative, 2:Transcode
        keyValues[Keys.videoEncoder] = 1       // 0:H.264, 1:ProRes422
        keyValues[Keys.deinterlace] = false    // deinterlace while decoding
        keyValues[Keys.videoStyle] = VideoStyle.SD_720_480_16_9.rawValue
        keyValues[Keys.clapOffsetH] = 0        // SD:+8..-8, HD:+16..-16
        keyValues[Keys.clapOffsetV] = 0        // SD:+8..-8, HD:+16..-16
        keyValues[Keys.videoTimeScale] = 30000 // Video media track time resolution
        keyValues[Keys.audioFormat] = 1        // 1:Decompressed, 2:Transcode
        keyValues[Keys.timeCodeFormat] = 0     // 0:None, 32:tmcd, 64:tc64
        
        keyValues[Keys.useMuxed] = true        // Prefer muxed device than separated
        keyValues[Keys.maxDuration] = 720      // max duration in min.
        keyValues[Keys.recordFor] = 30         // recording duration in min.
        keyValues[Keys.prefix] = "recdv2-"     // movie name prefix
        keyValues[Keys.showAlternate] = false  // Disable video preview
        keyValues[Keys.forceMute] = false      // Disable audio preview
        keyValues[Keys.hideInvisible] = false  // Hide video preview when invisible
        keyValues[Keys.suspendConnection] = false // Suspend video preview connection
        
        defaults.register(defaults: keyValues)
        
        // Start session
        let muxedID : String? = defaults.value(forKey: Keys.uniqueIDMuxed) as? String
        let videoID : String? = defaults.value(forKey: Keys.uniqueIDVideo) as? String
        let audioID : String? = defaults.value(forKey: Keys.uniqueIDAudio) as? String
        startSession(muxed: muxedID, video: videoID, audio: audioID)
        
        // Show window now
        window.titleVisibility = .hidden
        _ = window.setFrameAutosaveName(NSWindow.FrameAutosaveName(Keys.previewWindow))
        window.makeKeyAndOrderFront(self)
        window.delegate = self
        
        // Update Toolbar button title
        setVolume(-1)                       // Update Popup Menu Selection
        setScale(-1)                        // Update Popup Menu Selection
        
        // Start Status Update
        startUpdateStatus()
        
        // Update AppIcon to inactive state
        NSApp.applicationIconImage = iconInactive
        
        installSignalHandler()
        
        startActivity()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Reset AppIcon badge to inactive state
        NSApp.dockTile.badgeLabel = nil
        
        // Stop Status Update
        stopUpdateStatus()
        
        // Stop Session
        removePreviewLayer()
        stopSession()
        
        // Resign notification observer
        notificationCenter.removeObserver(self)
        
        endActivity()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // print("\(#file) \(#line) \(#function)")
        
        return true
    }
    
    /* ======================================================================================== */
    // MARK: - Variables
    /* ======================================================================================== */
    
    lazy var defaults = UserDefaults.standard
    lazy var notificationCenter = NotificationCenter.default
    
    var manager : AVCaptureManager? = nil
    var subLayerReady : Bool = false
    var updateTimer : Timer? = nil
    var stopTimer : Timer? = nil
    
    var limitFlag : Bool = false
    var targetPath : String? = nil
    
    var iconActiveState = false
    let iconInactive = NSImage(named:NSImage.Name(Keys.inactive))
    let iconActive = NSImage(named:NSImage.Name(Keys.active))
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var parentView: NSView!
    @IBOutlet weak var recordForMin: NSTextField!
    
    @IBOutlet weak var recordingButton: NSButton!
    @IBOutlet weak var scalePopup: NSPopUpButton!
    @IBOutlet weak var volumePopup: NSPopUpButton!
    
    @IBOutlet weak var scaleNow: NSMenuItem!
    @IBOutlet weak var volumeNow: NSMenuItem!
    
    @IBOutlet weak var accessoryView: NSView!
    
    /* ======================================================================================== */
    // MARK: - IBAction
    /* ======================================================================================== */
    
    @IBAction func volumeUp(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        var volTag = defaults.integer(forKey: Keys.volume)
        volTag += 5
        volTag = (volTag > 100 ? 100 : volTag)
        setVolume(volTag)
    }
    
    @IBAction func volumeDown(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        var volTag = defaults.integer(forKey: Keys.volume)
        volTag -= 5
        volTag = (volTag < 0 ? 0 : volTag)
        setVolume(volTag)
    }
    
    @IBAction func updateVolume(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        if sender is NSMenuItem {
            let volTag = (sender as! NSMenuItem).tag
            setVolume(volTag)
        }
        if sender is NSPopUpButton {
            let volTag = (sender as! NSPopUpButton).selectedTag()
            setVolume(volTag)
        }
    }
    
    @IBAction func scaleUp(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        var scaleTag = defaults.integer(forKey: Keys.scale)
        scaleTag += 5
        scaleTag = (scaleTag > 200 ? 200 : scaleTag)
        setScale(scaleTag)
    }
    
    @IBAction func scaleDown(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        var scaleTag = defaults.integer(forKey: Keys.scale)
        scaleTag -= 5
        scaleTag = (scaleTag < 50 ? 50 : scaleTag)
        setScale(scaleTag)
    }
    
    @IBAction func updateScale(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        if sender is NSMenuItem {
            let scaleTag = (sender as! NSMenuItem).tag
            setScale(scaleTag)
        }
        if sender is NSPopUpButton {
            let scaleTag = (sender as! NSPopUpButton).selectedTag()
            setScale(scaleTag)
        }
    }
    
    @IBAction func updateAspectRatio(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        if sender is NSMenuItem {
            let ratioTag = (sender as! NSMenuItem).tag
            setAspectRatio(ratioTag)
        }
        if sender is NSPopUpButton {
            let ratioTag = (sender as! NSPopUpButton).selectedTag()
            setAspectRatio(ratioTag)
        }
    }
    
    @IBAction func togglePreviewAudio(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        DispatchQueue.main.async(execute: {[unowned self] in
            self.setVolume(-1)                       // Update Popup Menu Selection
        })
    }
    
    @IBAction func togglePreviewVideo(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        DispatchQueue.main.async(execute: {[unowned self] in
            self.setScale(-1)                        // Update Popup Menu Selection
        })
    }
    
    @IBAction func toggleRecording(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        if modifier(NSEvent.ModifierFlags.option) {
            if let manager = manager, manager.isRecording() {
                // Reject multiple request
                recordingButton.state = NSControl.StateValue.on   // Reset button state
                NSSound.beep()
            } else {
                // Show a save panel sheet
                recordingButton.state = NSControl.StateValue.off  // Reset button state
                actionRecordingFor(sender)
            }
        } else {
            if recordingButton.state == NSControl.StateValue.on {
                // Start recording
                DispatchQueue.main.async(execute: {[unowned self] in
                    self.targetPath = nil       // Use autogenerated movie path
                    self.startRecording(for: 0)
                })
            } else {
                // Stop recording
                DispatchQueue.main.async(execute: {[unowned self] in
                    self.stopRecording()
                })
            }
        }
    }
    
    @IBAction func actionStartRecording(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        // Reject multiple request
        if let manager = manager, (manager.isRecording() || window.attachedSheet != nil) {
            NSSound.beep()
            return
        }
        
        //
        DispatchQueue.main.async(execute: {[unowned self] in
            self.targetPath = nil           // Use autogenerated movie path
            self.startRecording(for:0)
        })
    }
    
    @IBAction func actionStopRecording(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        //
        DispatchQueue.main.async(execute: {[unowned self] in
            self.stopRecording()
        })
    }
    
    @IBAction func actionRecordingFor(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        // Reject multiple request
        if let manager = manager, (manager.isRecording() || window.attachedSheet != nil) {
            NSSound.beep()
            return
        }
        
        // Setup save panel
        let panel = NSSavePanel()
        panel.prompt = "Start Recording"
        panel.directoryURL = movieFolder()
        panel.nameFieldStringValue = movieName()
        panel.accessoryView = accessoryView
        
        // Update duration textfield (in minutes)
        let min = defaults.integer(forKey: Keys.recordFor)
        self.recordForMin.integerValue = min
        
        // Present as a sheet
        panel.beginSheetModal(for: window, completionHandler: {[unowned self] result in
            // print("\(#file) \(#line) \(#function)")
            
            if result == NSApplication.ModalResponse.OK {
                // Update movie file path
                if let targetURL = panel.url {
                    self.targetPath = targetURL.path    // Use specified file path
                } else {
                    self.targetPath = nil   // Use autogenerated file path
                }
                
                // New value from duration textfield (in minutes)
                let min = self.recordForMin.integerValue
                self.defaults.set(min, forKey: Keys.recordFor)
                
                //
                DispatchQueue.main.async(execute: {[unowned self] in
                        self.startRecording(for: min * 60)
                })
            }
        })
    }
    
    @IBAction func actionSetFolder(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        // Setup open panel
        let panel = NSOpenPanel()
        panel.prompt = "Set as Default"
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.directoryURL = movieFolder()!
        
        // Present as a sheet
        panel.beginSheetModal(for: window, completionHandler: {[unowned self] (result) in
            // print("\(#file) \(#line) \(#function)")
            
            if result == NSApplication.ModalResponse.OK, let url = panel.url {
                self.defaults.set(url, forKey: Keys.movieFolder)
            }
        })
        
    }
    
    @IBAction func printSettionDiag(_ sender: AnyObject) {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager {
            manager.printSessionDiag()
        }
    }
    
    /* ======================================================================================== */
    // MARK: - Capture Session support
    /* ======================================================================================== */
    
    func startSession(muxed muxedID: String?, video videoID: String?, audio audioID: String?) {
        // print("\(#file) \(#line) \(#function)")
        
        manager = AVCaptureManager()
        if let manager = manager {
            let useMuxed = defaults.bool(forKey: Keys.useMuxed)
            
            manager.useMuxed = useMuxed
            manager.usePreset = false
            _ = manager.openSessionForUniqueID(muxed: useMuxed ? muxedID : nil,
                                               video: useMuxed ? nil : videoID,
                                               audio: useMuxed ? nil : audioID)
        }
    }
    
    func stopSession() {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager {
            manager.closeSession()
            self.manager = nil
        }
    }
    
    func restartSession(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        var muxedID : String? = nil
        var videoID : String? = nil
        var audioID : String? = nil
        if let userInfo = notification.userInfo {
            if let item = userInfo[Keys.uniqueIDMuxed] as? String {
                muxedID = item
            }
            if let item = userInfo[Keys.uniqueIDVideo] as? String {
                videoID = item
            }
            if let item = userInfo[Keys.uniqueIDAudio] as? String {
                audioID = item
            }
        }
        
        // Stop Session
        DispatchQueue.main.async(execute: {[unowned self] in
            self.removePreviewLayer()
            self.stopSession()
        })
        
        // Start Session
        DispatchQueue.main.async(execute: {[unowned self] in
            self.startSession(muxed: muxedID, video: videoID, audio: audioID)
            
            // Update Toolbar button title
            self.setScale(-1)               // Update Popup Menu Selection
            self.setVolume(-1)              // Update Popup Menu Selection
            
            // Update Defaults as is
            if let muxedID = muxedID {
                self.defaults.setValue(muxedID, forKey: Keys.uniqueIDMuxed)
            }
            if let videoID = videoID {
                self.defaults.setValue(videoID, forKey: Keys.uniqueIDVideo)
            }
            if let audioID = audioID {
                self.defaults.setValue(audioID, forKey: Keys.uniqueIDAudio)
            }
        })
    }
    
    /* ======================================================================================== */
    // MARK: - Recording support
    /* ======================================================================================== */
    
    func startRecording(for sec: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager, let movieURL = createMovieURL() {
            // Read parameters for recording
            let useNative = (defaults.integer(forKey: Keys.videoFormat) == 0)
            let useLPCM = (defaults.integer(forKey: Keys.audioFormat) == 1)
            let deinterlace = defaults.bool(forKey: Keys.deinterlace)
            let timeScale = defaults.integer(forKey: Keys.videoTimeScale)
            let useH264 = (defaults.integer(forKey: Keys.videoEncoder) == 0)
            let videoStyle = defaults.string(forKey: Keys.videoStyle)!
            let clapOffsetH = defaults.integer(forKey: Keys.clapOffsetH)
            let clapOffsetV = defaults.integer(forKey: Keys.clapOffsetV)
            let timeCodeFormat = defaults.integer(forKey: Keys.timeCodeFormat)
            
            // Apply parameters for recording
            if useNative {
                manager.encodeVideo = false
                manager.encodeDeinterlace = false
            } else {
                manager.encodeVideo = true
                manager.encodeDeinterlace = deinterlace
            }
            if useLPCM {
                manager.encodeAudio = false
            } else {
                manager.encodeAudio = true
            }
            switch timeCodeFormat {
            case 32:
                manager.timeCodeFormatType = kCMTimeCodeFormatType_TimeCode32
            case 64:
                manager.timeCodeFormatType = kCMTimeCodeFormatType_TimeCode64
            default:
                manager.timeCodeFormatType = nil
            }
            manager.sampleTimescaleVideo = Int32(timeScale)
            manager.encodeProRes422 = !useH264
            manager.videoStyle = VideoStyle(rawValue: videoStyle)! //.SD_720_480_16_9
            manager.clapHOffset = clapOffsetH
            manager.clapVOffset = clapOffsetV
            
            // Start recording to specified URL
            manager.startRecording(to: movieURL)
            
            /* ============================================================================== */
            
            // Schedule StopTimer if required
            scheduleStopTimer(sec)
            
            // Update recording button as pressed state
            recordingButton.state = NSControl.StateValue.on
            
            // Update AppIcon badge to REC state
            NSApp.dockTile.badgeLabel = "REC"
            
            // Post notification with userInfo
            let userInfo : [String:Any] = [Keys.fileURL : movieURL]
            let notification = Notification(name: .recordingStartedNotificationKey,
                                            object: self,
                                            userInfo: userInfo)
            notificationCenter.post(notification)
        } else {
            print("ERROR: Failed to start recording.")
        }
    }
    
    func stopRecording() {
        // print("\(#file) \(#line) \(#function)")
        
        // Update recording button as released state
        recordingButton.state = NSControl.StateValue.off
        
        // Release StopTimer
        invalidateStopTimer()
        
        // Stop recording
        if let manager = manager {
            if manager.isRecording() {
                manager.stopRecording()
                
                // Reset AppIcon badge to inactive state
                NSApp.dockTile.badgeLabel = nil
                
                // Post notification without userInfo
                let notification = Notification(name: .recordingStoppedNotificationKey,
                                                object: self,
                                                userInfo: nil)
                notificationCenter.post(notification)
            }
        }
        
        // Handle AutoQuit after finished
        if limitFlag && defaults.bool(forKey: Keys.autoQuit) {
            //
            DispatchQueue.main.async(execute: {[unowned self] in
                    NSApp.terminate(self)
            })
        }
    }
    
    private func scheduleStopTimer(_ sec: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        // Release existing StopTimer
        invalidateStopTimer()
        
        if sec > 0 {
            // Setup new StopTimer
            var limit: Double = 0
            let max = defaults.integer(forKey: Keys.maxDuration) * 60 // in seconds
            if max > sec {
                limit = Double(sec)         // hang up on requested minutes
                limitFlag = true
            } else {
                limit = Double(max)         // limit in maxDuration minutes
                limitFlag = false
            }
            
            stopTimer = Timer.scheduledTimer(timeInterval: limit,
                                             target: self,
                                             selector: #selector(stopRecording),
                                             userInfo: nil,
                                             repeats: false)
        }
    }
    
    private func invalidateStopTimer() {
        // print("\(#file) \(#line) \(#function)")
        
        // Release StopTimer
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
            self.stopTimer = nil
        }
    }
    
    /* ======================================================================================== */
    // MARK: - Misc support
    /* ======================================================================================== */
    
    private func modifier(_ mask: NSEvent.ModifierFlags) -> Bool {
        // print("\(#file) \(#line) \(#function)")
        
        // example : .option, .control, .command, .shift
        
        if let event = NSApp.currentEvent {
            let flag = event.modifierFlags
            return flag.contains(mask)
        }
        return false
    }
    
    private func movieFolder() -> URL? {
        // print("\(#file) \(#line) \(#function)")
        
        if let url = defaults.url(forKey: Keys.movieFolder) {
            var error:NSError?
            if (url as NSURL).checkResourceIsReachableAndReturnError(&error) {
                var flagDirectory = false
                var flagWritable = false
                
                // validate access
                let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey, .isWritableKey])
                if let resourceValues = resourceValues {
                    flagDirectory = resourceValues.isDirectory!
                    flagWritable = resourceValues.isWritable!
                }
                
                if flagDirectory && flagWritable {
                    return url
                }
            }
        }
        
        // Use Movie folder
        let directory = FileManager.SearchPathDirectory.moviesDirectory
        let domainMask = FileManager.SearchPathDomainMask.userDomainMask
        let movieFolders = NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
        if let folderPath = movieFolders.first {
            let folderURL = URL.init(fileURLWithPath: folderPath)
            return folderURL
        }
        
        // Fallback to user's home directory
        return URL.init(fileURLWithPath: NSHomeDirectory())
    }
    
    private func movieName() -> String {
        // Generate Movie file name
        let prefix = defaults.value(forKey: Keys.prefix) as! String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd-HHmmss"
        let movieName = prefix + formatter.string(from: Date()) + ".mov"
        return movieName
    }
    
    private func createMovieURL() -> URL? {
        // print("\(#file) \(#line) \(#function)")
        
        // Scripting support for target movie path
        if let targetPath = targetPath {
            return URL(fileURLWithPath: targetPath)
        }
        
        //
        if let movieFolder = movieFolder() {
            let targetURL = movieFolder.appendingPathComponent(movieName())
            targetPath = targetURL.path
            return targetURL
        }
        
        return nil
    }
    
    /* ======================================================================================== */
    // MARK: - Status label support
    /* ======================================================================================== */
    
    private func startUpdateStatus() {
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
    
    private func stopUpdateStatus() {
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
    
    func updateStatus(_ status: String?) {
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
    
    /* ======================================================================================== */
    // MARK: - Volume control support
    /* ======================================================================================== */
    
    private func setVolume(_ volume: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        let forceMute = defaults.bool(forKey: Keys.forceMute)
        if volume >= 0 {
            defaults.set(volume, forKey:Keys.volume)
            
            if let manager = manager {
                manager.volume = (forceMute ? 0.0 : Float(volume) / 100.0)
            }
            
            updateCurrentVolume()
        } else {
            let prevVolume = defaults.integer(forKey: Keys.volume)
            
            if let manager = manager {
                manager.volume = (forceMute ? 0.0 : Float(prevVolume) / 100.0)
            }
        }
        
        volumePopup.selectItem(withTag: -1) // TODO
    }
    
    private func updateCurrentVolume() {
        // print("\(#file) \(#line) \(#function)")
        
        // Update currentVolume title of NSPopupButton
        let volume = defaults.integer(forKey: Keys.volume)
        
        let currentVolume = "Vol: \(volume)%"
        defaults.setValue(currentVolume, forKey: Keys.currentVolume)
    }
    
    /* ======================================================================================== */
    // MARK: - Window resizing support
    /* ======================================================================================== */
    
    func windowDidResize(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        if let layer = self.parentView.layer  {
            layoutSublayers(of: layer)
        }
    }

    private func setAspectRatio(_ ratioTag: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        defaults.set(ratioTag, forKey: Keys.aspectRatio)
        
        resizeAspect()
    }
    
    private func setScale(_ scaleTag: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        if scaleTag > 0 {
            defaults.set(scaleTag, forKey: Keys.scale)
            
            resizeScale()
            
            // updateCurrentScale() // Update later in layoutSublayersOfLayer()
        } else {
            // Do nothing
        }
        
        scalePopup.selectItem(withTag: -1) // TODO
    }
    
    private func updateCurrentScale() {
        // print("\(#file) \(#line) \(#function)")
        
        // Update currentScale title of NSPopupButton
        var scaleTag = defaults.integer(forKey: Keys.scale)
        
        if let manager = manager, let previewLayer = manager.previewLayer, let nativeSize = manager.videoSize {
            let scale: CGFloat = 100.0 * previewLayer.bounds.size.height / nativeSize.height
            scaleTag = Int(scale + 0.05)
        }
        
        let currentScale = "Scale: \(scaleTag)%"
        defaults.setValue(currentScale, forKey: Keys.currentScale)
    }
    
    private func resizeAspect() {
        // print("\(#file) \(#line) \(#function)")
        
        // Resize Window Horizontally using pixel aspect ratio
        if let window = parentView.window, let manager = manager, let nativeSize = manager.videoSize {
            let contentSize = window.contentView!.bounds.size
            let topOffset: CGFloat = window.frame.size.height - contentSize.height
            
            let targetRatio: CGFloat = apertureRatio() * nativeSize.width / nativeSize.height
            let newContentSize = CGSize(width: contentSize.height * targetRatio, height: contentSize.height)
            
            // Preserve top center
            let newRect = CGRect(x: window.frame.midX - newContentSize.width/2.0,
                                 y: window.frame.maxY - newContentSize.height - topOffset,
                                 width: newContentSize.width,
                                 height: newContentSize.height + topOffset)
            window.setFrame(newRect, display: true, animate: true)
        }
    }
    
    private func resizeScale() {
        // print("\(#file) \(#line) \(#function)")
        
        // Resize Window using specified scale value
        if let window = parentView.window, let manager = manager, let nativeSize = manager.videoSize {
            let contentSize = window.contentView!.bounds.size
            let topOffset: CGFloat = window.frame.size.height - contentSize.height
            
            let targetRatio: CGFloat = apertureRatio() * nativeSize.width / nativeSize.height
            let newContentSize = CGSize(width: nativeSize.height * targetRatio * scale(),
                                        height: nativeSize.height * scale())
            
            // Preserve top center
            let newRect = CGRect(x: window.frame.midX - newContentSize.width/2.0,
                                 y: window.frame.maxY - newContentSize.height - topOffset,
                                 width: newContentSize.width,
                                 height: newContentSize.height + topOffset)
            window.setFrame(newRect, display: true, animate: true)
        }
    }
    
    private func apertureRatio() -> CGFloat {
        // print("\(#file) \(#line) \(#function)")
        
        var ratio: CGFloat = 1.0
        let ratioTag = defaults.integer(forKey: Keys.aspectRatio)
        
        if ratioTag > 1001 {
            let numerator: CGFloat = CGFloat(ratioTag / 1000)
            let denominator: CGFloat = CGFloat(ratioTag % 1000)
            ratio = numerator/denominator
        }
        return ratio
    }
    
    private func scale() -> CGFloat {
        // print("\(#file) \(#line) \(#function)")
        
        var scale: CGFloat = 1.0
        let scaleTag = defaults.integer(forKey: Keys.scale)
        
        if scaleTag >= 50 {
            scale = CGFloat(scaleTag)/100.0
        }
        return scale
    }
    
    /* ======================================================================================== */
    // MARK: - Preview Layer support
    /* ======================================================================================== */
    
    private func checkOnActiveSpace() {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager {
            let showAlternate = defaults.bool(forKey: Keys.showAlternate)
            
            let onActive = window.isOnActiveSpace
            let hideInvisible = defaults.bool(forKey: Keys.hideInvisible)
            
            let value = !showAlternate && (onActive ? onActive : !hideInvisible)
            
            if value == true && subLayerReady == false {
                addPreviewLayer()
            }
            if value == false && subLayerReady == true {
                removePreviewLayer()
            }
            
            // BUG: AVCapturePreviewLayer fill up system.log on inactive space
            let suspendConnection = defaults.bool(forKey: Keys.suspendConnection)
            if suspendConnection {
                manager.setVideoPreviewConnection(enabled: value)
            } else {
                manager.setVideoPreviewConnection(enabled: true)
            }
        }
    }
    
    private func applyApertureRatio() {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager, let previewLayer = manager.previewLayer, let superLayer = parentView.layer {
            //print(">> applyApertureRatio()")
            
            let superLayerSize = superLayer.bounds.size
            let subLayerSize = preferredSize(of: previewLayer)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            previewLayer.videoGravity = AVLayerVideoGravity.resize
            previewLayer.frame = CGRect(x: (superLayerSize.width-subLayerSize.width)/2,
                                        y: (superLayerSize.height-subLayerSize.height)/2,
                                        width: subLayerSize.width,
                                        height: subLayerSize.height)
            CATransaction.commit()
            
            //print("<< applyApertureRatio()")
        }
    }
    
    private func addPreviewLayer() {
        // print("\(#file) \(#line) \(#function)")
        
        // Check if already added
        if subLayerReady == true {
            return
        }
        
        // Check if video preview is disabled
        if defaults.bool(forKey: Keys.showAlternate) {
            return
        }
        
        // Ensure CALayer for the ParentView
        if parentView.wantsLayer == false {
            parentView.wantsLayer = true
        }
        
        // Check if video is ready to display
        if let manager = manager {
            if manager.videoSize == nil {
                print("addPreviewLayer() - delayed")
                
                // delay 1 frame (around 1/30 sec)
                let delay = DispatchTime.now() + DispatchTimeInterval.milliseconds(33)
                DispatchQueue.main.asyncAfter(deadline: delay, execute: {[unowned self] in
                    self.addPreviewLayer()
                })
                return
            }
        }
        
        if let manager = manager, let previewLayer = manager.previewLayer, let superLayer = parentView.layer {
            // Set background color
            let grayColor = CGColor(gray: 0.25, alpha: 1.0)
            superLayer.backgroundColor = grayColor
            
            // Apply video aspect ratio (considering clean aperture)
            applyApertureRatio()
            
            // Add preview sublayer
            superLayer.delegate = self
            previewLayer.delegate = self
            superLayer.addSublayer(previewLayer)
            
            subLayerReady = true
            
            return
        }
        
        print("ERROR: Failed to addPreviewLayer()")
    }
    
    private func removePreviewLayer() {
        // print("\(#file) \(#line) \(#function)")
        
        // Check if already removed
        if subLayerReady == false {
            return
        }
        
        if let manager = manager, let previewLayer = manager.previewLayer, let superLayer = parentView.layer {
            // Remove preview sublayer
            superLayer.delegate = nil
            previewLayer.delegate = nil
            previewLayer.removeFromSuperlayer()
            
            subLayerReady = false
        }
    }
    
    /* ======================================================================================== */
    // MARK: - CALayoutManager Protocol
    /* ======================================================================================== */
    
    func preferredSize(of layer: CALayer) -> CGSize {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager, let previewLayer = manager.previewLayer, let superLayer = parentView.layer {
            switch layer {
            case previewLayer:
                //print(">>>preferredSizeOfLayer()")
                
                let superLayerSize = superLayer.bounds.size
                let superLayerAspect: CGFloat = superLayerSize.width / superLayerSize.height
                
                var requestAspect: CGFloat = 0.0
                if let videoSize = manager.videoSize {
                    requestAspect = (videoSize.width / videoSize.height) * apertureRatio()
                } else {
                    requestAspect = (4.0/3.0) * apertureRatio()
                }
                
                let adjustRatio: CGFloat = requestAspect / superLayerAspect
                
                var subLayerSize = CGSize.zero
                if superLayerAspect < requestAspect {
                    // Shrink vertically
                    subLayerSize = CGSize(width: superLayerSize.width  ,
                                          height: superLayerSize.height / adjustRatio)
                } else {
                    // Shrink horizontally
                    subLayerSize = CGSize(width: superLayerSize.width  * adjustRatio,
                                          height: superLayerSize.height )
                }
                
                //print("<<<preferredSizeOfLayer()")
                return subLayerSize
            case superLayer:
                break
            default:
                break
            }
        }
        
        return layer.bounds.size
    }
    
    func layoutSublayers(of layer: CALayer) {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager, let previewLayer = manager.previewLayer, let superLayer = parentView.layer {
            // print("\n>  layoutSublayersOfLayer(\(layer))")
            
            switch layer {
            case superLayer:
                applyApertureRatio()
                updateCurrentScale()
                break
            case previewLayer:
                break
            default:
                break
            }
            
            //print("<  layoutSublayersOfLayer(\(layer))")
            return
        }
    }
}

