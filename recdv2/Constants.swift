//
//  Constants.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/24.
//  Copyright © 2016-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Foundation

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for Notification.Name extension
/* ======================================================================================== */

extension Notification.Name {
    static let RDV2RecordingStateChangedKey = Notification.Name("RDV2RecordingStateChanged")
    static let RDV2SessionStateChangedKey = Notification.Name("RDV2SessionStateChanged")
    
    static let RDV2RestartSessionCommandKey = Notification.Name("RDV2RestartSessionCommand")
    static let RDV2StopRecordingCommandKey = Notification.Name("RDV2StopRecordingCommand")
    static let RDV2StartRecordingCommandKey = Notification.Name("RDV2StartRecordingCommand")
}

/* ======================================================================================== */
// MARK: - Application support; for Notification.Name extension
/* ======================================================================================== */

extension Notification.Name {
    static let recordingStartedNotificationKey = Notification.Name("recordingStartedNotification")
    static let recordingStoppedNotificationKey = Notification.Name("recordingStoppedNotification")
    
    static let restartSessionNotificationKey = Notification.Name("restartSessionNotification")
    static let validateCompressionSettingsNotificationKey = Notification.Name("validateCompressionSettingsNotification")
}

/* ======================================================================================== */
// MARK: - Shared Keys enumeration for Cocoa bindings, Dictionary Keys, UserDefaults, etc.
/* ======================================================================================== */

enum Keys {
    static let fileURL = "fileURL"
    static let maxSeconds = "maxSeconds"
    static let autoQuit = "autoQuit"
    
    static let movieFolder = "movieFolder"
    
    static let sessionItem = "sessionItem"
    static let recordingItem = "recordingItem"
    static let folderURL = "folderURL"
    static let useVideoPreview = "useVideoPreview"
    static let useAudioPreview = "useAudioPreview"
    
    static let aspectRatio = "aspectRatio"
    static let scale = "scale"
    static let volume = "volume"
    static let volumeTag = "volumeTag"
    static let scaleTag = "scaleTag"
    
    static let videoFormat = "videoFormat"
    static let videoEncoder = "videoEncoder"
    static let deinterlace = "deinterlace"
    static let videoStyle = "videoStyle"
    static let clapOffsetH = "clapOffsetH"
    static let clapOffsetV = "clapOffsetV"
    static let videoTimeScale = "videoTimeScale"
    
    static let pixelFormatType = "pixelFormatType"
    static let videoFrameRate = "videoFrameRate"
    static let proresEncoderType = "proresEncoderType"
    static let videoEncoderType = "videoEncoderType"
    static let videoEncoderProfile = "videoEncoderProfile"
    static let videoEncoderBitRate = "videoEncoderBitRate"
    
    static let audioFormat = "audioFormat"
    
    static let audioEncoderType = "audioEncoderType"
    static let audioEncoderBitRate = "audioEncoderBitRate"
    static let audioEncoderStrategy = "audioEncoderStrategy"
    
    static let timeCodeFormat = "timeCodeFormat"
    
    static let useMuxed = "useMuxed"
    static let maxDuration = "maxDuration"
    static let recordFor = "recordFor"
    static let prefix = "prefix"
    static let showAlternate = "showAlternate"
    static let forceMute = "forceMute"
    static let hideInvisible = "hideInvisible"
    static let suspendConnection = "suspendConnection"
    
    static let uniqueIDMuxed = "uniqueIDMuxed"
    static let uniqueIDVideo = "uniqueIDVideo"
    static let uniqueIDAudio = "uniqueIDAudio"
    
    static let previewWindow = "previewWindow"
    
    static let inactive = "inactive"
    static let active = "active"
    
    static let statusVisible = "statusVisible"
    static let statusString = "statusString"
    
    static let currentVolume = "currentVolume"
    static let currentScale = "currentScale"
    
    static let uniqueID = "uniqueID"
    static let modelID = "modelID"
    static let localizedName = "localizedName"
    static let manufacturer = "manufacturer"
    static let transportType = "transportType"
    static let connected = "connected"
    static let inUseByAnotherApplication = "inUseByAnotherApplication"
    static let suspended = "suspended"
    
    static let newSessionData = "newSessionData"
    static let newRecordingData = "newRecordingData"
}

