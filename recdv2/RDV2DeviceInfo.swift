//
//  RDV2DeviceInfo.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/11.
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
// MARK: - Cocoa scripting support; for Script class RDV2DeviceInfo and subclasses
/* ======================================================================================== */

@objcMembers
class RDV2DeviceInfoMuxed: RDV2DeviceInfo {
    override var name: String {
        get {
            if super.name.count > 0 {
                return super.name
            }
            if let localized = super.localizedName {
                return "Muxed: " + localized
            } else {
                return "Muxed device info"
            }
        }
        set {super.name = newValue}
    }
}

@objcMembers
class RDV2DeviceInfoVideo: RDV2DeviceInfo {
    override var name: String {
        get {
            if super.name.count > 0 {
                return super.name
            }
            if let localized = super.localizedName {
                return "Video: " + localized
            } else {
                return "Video device info"
            }
        }
        set {super.name = newValue}
    }
}

@objcMembers
class RDV2DeviceInfoAudio: RDV2DeviceInfo {
    override var name: String {
        get {
            if super.name.count > 0 {
                return super.name
            }
            if let localized = super.localizedName {
                return "Audio: " + localized
            } else {
                return "Audio device info"
            }
        }
        set {super.name = newValue}
    }
}

@objcMembers
class RDV2DeviceInfo: NSObject {
    /* ============================================================================== */
    
    var name: String = ""
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
    
    var deviceUniqueID: String? = nil
    var modelID: String? = nil
    var localizedName: String? = nil
    var manufacturer: String? = nil
    var transportType: String? = nil
    var connected: Bool = false
    var inUseByAnotherApplication: Bool = false
    var suspended: Bool = false
    
    /* ============================================================================== */
    
    convenience init?(from info : Any) {
        self.init()
        guard let obj = info as? Dictionary<String, Any> else { return nil }
        
        deviceUniqueID = obj[Keys.uniqueID] as? String
        modelID = obj[Keys.modelID] as? String
        localizedName = obj[Keys.localizedName] as? String
        manufacturer = obj[Keys.manufacturer] as? String
        transportType = obj[Keys.transportType] as? String
        connected = obj[Keys.connected] as! Bool
        inUseByAnotherApplication = obj[Keys.inUseByAnotherApplication] as! Bool
        suspended = obj[Keys.suspended] as! Bool
    }
}
