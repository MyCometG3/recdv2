//
//  RDV2DeviceInfo.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2016/09/11.
//  Copyright © 2016-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

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
    
    var contDescription : NSScriptClassDescription? = nil
    var contSpecifier : NSScriptObjectSpecifier? = nil
    var contKey : String? = nil
    override var objectSpecifier: NSScriptObjectSpecifier? {
        //let specifier = NSUniqueIDSpecifier(containerClassDescription: contDescription!,
        //                                    containerSpecifier: contSpecifier,
        //                                    key: contKey!,
        //                                    uniqueID: self.uniqueID)
        let specifier = NSNameSpecifier(containerClassDescription: contDescription!,
                                        containerSpecifier: contSpecifier,
                                        key: contKey!,
                                        name: self.name)
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
