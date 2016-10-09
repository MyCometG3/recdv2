//
//  Constants.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/24.
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

import Foundation

/* ======================================================================================== */
// MARK: - Cocoa scripting support; for Notification.Name extension
/* ======================================================================================== */

extension Notification.Name {
    static let RDV2RecordingChangedKey = Notification.Name("RDV2RecordingChanged")
    
    static let RDV2SessionChangedKey = Notification.Name("RDV2SessionChanged")

    static let handleRestartSessionKey = Notification.Name("handleRestartSession")
    static let handleStopRecordingKey = Notification.Name("handleStopRecording")
    static let handleStartRecordingKey = Notification.Name("handleStartRecording")
}

/* ======================================================================================== */
// MARK: - Application support; for Notification.Name extension
/* ======================================================================================== */

extension Notification.Name {
    static let recordingStartedNotificationKey = NSNotification.Name("RecordingStartedNotification")
    static let recordingStoppedNotificationKey = NSNotification.Name("RecordingStoppedNotification")
    
    static let restartSessionNotificationKey = Notification.Name("restartSessionNotification")
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
    static let audioFormat = "audioFormat"
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

