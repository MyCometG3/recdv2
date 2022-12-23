//
//  AppDelegate+Volume.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/23.
//  Copyright © 2022 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa

extension AppDelegate {
    
    /* ======================================================================================== */
    // MARK: - Volume control support
    /* ======================================================================================== */
    
    func setVolume(_ volume: Int) {
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
    
}
