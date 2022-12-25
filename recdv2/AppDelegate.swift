//
//  AppDelegate.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/08/14.
//  Copyright © 2016-2022 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa
import AVFoundation
import AVCaptureManager

@NSApplicationMain
@objcMembers
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /* ======================================================================================== */
    // MARK: - NSApplicationDelegate protocol
    /* ======================================================================================== */
    
    func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
        // print("\(#file) \(#line) \(#function)")
        
        return checkSupportedScriptingKey(key)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        // Register notification observer for Cocoa scripting support
        registerObserverForScriptingSupport()
        
        // Register notification observer for Restarting AVCaptureSession
        notificationCenter.addObserver(self,
                                       selector: #selector(restartSession),
                                       name: .restartSessionNotificationKey,
                                       object: nil)
        
        // Register notification observer for Loading Compression Settings
        notificationCenter.addObserver(self,
                                       selector: #selector(loadCompressionSettings),
                                       name: .loadCompressionSettingsNotificationKey,
                                       object: nil)
        
        // Register defaults defautl values
        var keyValues:[String:Any] = [:]
        keyValues[Keys.aspectRatio] = 40033    // 40:33 for DV-NTSC
        keyValues[Keys.scale] = 100            // Video preview scale 100%
        keyValues[Keys.volume] = 100           // Audio preview volume 100%
        keyValues[Keys.volumeTag] = -1         // -1:Vol: now%
        keyValues[Keys.scaleTag] = -1          // -1:Scale: now%
        
        keyValues[Keys.videoFormat] = 0        // 0:DeviceNative, 2:Transcode
        keyValues[Keys.videoEncoder] = 1       // 0:H26X, 1:ProRes
        keyValues[Keys.deinterlace] = false    // deinterlace while decoding
        keyValues[Keys.videoStyle] = VideoStyle.SD_720_480_16_9.rawValue
        keyValues[Keys.clapOffsetH] = 0        // SD:+8..-8, HD:+16..-16
        keyValues[Keys.clapOffsetV] = 0        // SD:+8..-8, HD:+16..-16
        keyValues[Keys.videoTimeScale] = 30000 // Video media track time resolution
        
        keyValues[Keys.pixelFormatType] = Int(kCMPixelFormat_422YpCbCr8) // 422-8bit or 422 10bit
        keyValues[Keys.videoFrameRate] = 0     // 0:DeviceNative, n:(1000 * FixedFrameRate)
        keyValues[Keys.proresEncoderType] = fourCC(avVideoCodecType: .proRes422)
        keyValues[Keys.videoEncoderType] = fourCC(avVideoCodecType: .h264)
        keyValues[Keys.videoEncoderProfile] = AVVideoProfileLevelH264High40
        keyValues[Keys.videoEncoderBitRate] = H264ProfileLevel.HiP_40.maxRate
        
        keyValues[Keys.audioFormat] = 1        // 1:Decompressed, 2:Transcode
        
        keyValues[Keys.audioEncoderType] = Int(kAudioFormatMPEG4AAC)
        keyValues[Keys.audioEncoderBitRate] = 256*1000
        keyValues[Keys.audioEncoderStrategy] = bitRateStrategy(tagFor:AVAudioBitRateStrategy_Constant)
        
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
    
    lazy var _sessionItem: RDV2Session = RDV2Session()
    lazy var _recordingItem: RDV2Recording = RDV2Recording()
    
    var activityToken : NSObjectProtocol? = nil
    
    var srcSIGTERM : DispatchSourceSignal? = nil
    var srcSIGUSR1 : DispatchSourceSignal? = nil
    var srcSIGUSR2 : DispatchSourceSignal? = nil
    
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
    
    /* ======================================================================================== */
    // MARK: - IBOutlet
    /* ======================================================================================== */
    
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
    
    func loadCompressionSettings(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager {
            // Read parameters for recording
            let useNative = (defaults.integer(forKey: Keys.videoFormat) == 0)
            let useLPCM = (defaults.integer(forKey: Keys.audioFormat) == 1)
            let deinterlace = defaults.bool(forKey: Keys.deinterlace)
            let timeScale = defaults.integer(forKey: Keys.videoTimeScale)
            let useH26X = (defaults.integer(forKey: Keys.videoEncoder) == 0)
            let videoStyle = defaults.string(forKey: Keys.videoStyle)!
            let clapOffsetH = defaults.integer(forKey: Keys.clapOffsetH)
            let clapOffsetV = defaults.integer(forKey: Keys.clapOffsetV)
            
            let pixelFormatType = defaults.integer(forKey: Keys.pixelFormatType)
            let videoFrameRate = defaults.integer(forKey: Keys.videoFrameRate)
            let proresEncoderType = defaults.integer(forKey: Keys.proresEncoderType)
            let videoEncoderType = defaults.integer(forKey: Keys.videoEncoderType)
            let videoEncoderProfile = defaults.string(forKey: Keys.videoEncoderProfile)!
            let videoEncoderBitRate = defaults.integer(forKey: Keys.videoEncoderBitRate)
            
            let audioEncoderType = defaults.integer(forKey: Keys.audioEncoderType)
            let audioEncoderBitRate = defaults.integer(forKey: Keys.audioEncoderBitRate)
            let audioEncoderStrategy = defaults.integer(forKey: Keys.audioEncoderStrategy)
            
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
            manager.sampleTimescaleVideo = Int32(timeScale)
            manager.encodeProRes = !useH26X
            manager.resetVideoStyle(VideoStyle(rawValue: videoStyle)!,
                                    hOffset: clapOffsetH, vOffset: clapOffsetV)
            
            manager.pixelFormatType = CMPixelFormatType(pixelFormatType)
            if videoFrameRate > 0 {
                let numerator = CMTimeValue(1000*timeScale/videoFrameRate)
                let denominator = CMTimeScale(timeScale)
                manager.sampleDurationVideo = CMTime(value: numerator, timescale: denominator)
            } else {
                manager.sampleDurationVideo = nil
            }
            manager.proresEncoderType = fourCC(cmVideoCodecType: CMVideoCodecType(proresEncoderType))
            manager.videoEncoderType = fourCC(cmVideoCodecType: CMVideoCodecType(videoEncoderType))
            manager.videoEncoderProfile = videoEncoderProfile
            manager.videoEncoderBitRate = videoEncoderBitRate
            
            manager.audioEncodeType = AudioFormatID(audioEncoderType)
            manager.audioEncoderBitRate = audioEncoderBitRate
            manager.audioEncoderStrategy = bitRateStrategy(AVAudioFor: audioEncoderStrategy)
            
            switch timeCodeFormat {
            case 32:
                manager.timeCodeFormatType = kCMTimeCodeFormatType_TimeCode32
            case 64:
                manager.timeCodeFormatType = kCMTimeCodeFormatType_TimeCode64
            default:
                manager.timeCodeFormatType = nil
            }
            
            //
            manager.resetCompressionSettings()
        }
    }
    
    /* ======================================================================================== */
    // MARK: - Recording support
    /* ======================================================================================== */
    
    func startRecording(for sec: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        if let manager = manager, let movieURL = createMovieURL() {
            // Load latest compression settings
            loadCompressionSettings(Notification(name: .loadCompressionSettingsNotificationKey))
            
            // Start recording to specified URL
            manager.startRecording(to: movieURL)
            
            if manager.isRecording() == false {
                NSSound.beep()
                
                // Update AppIcon badge to Err state
                NSApp.dockTile.badgeLabel = "Err"

                print("ERROR: Failed to start recording.")
                return
            }
            
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
    
    func movieFolder() -> URL? {
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
    
}
