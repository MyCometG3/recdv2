//
//  AppDelegate+CodecSupport.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/24.
//  Copyright © 2022-2023 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Foundation
import AVFoundation

extension AppDelegate {
    
    /* ======================================================================================== */
    //MARK: - FourCC String/Numeric conversion
    /* ======================================================================================== */
    
    func fourCC(avVideoCodecType codec: AVVideoCodecType) -> CMVideoCodecType {
        let src: String = codec.rawValue
        let fourCC: UInt32 = fourCC(str: src)
        return CMVideoCodecType(fourCC)
    }
    
    private func fourCC(str src: String) -> UInt32 {
        var fourCC: UInt32 = 0
        if (src.count == 4 && src.utf8.count == 4) {
            for char: UInt8 in src.utf8 {
                fourCC = (fourCC << 8) | UInt32(char)
            }
        }
        return fourCC
    }
    
    func fourCC(cmVideoCodecType codec: CMVideoCodecType) -> AVVideoCodecType {
        let src: UInt32 = UInt32(codec)
        let fourCC :String = fourCC(uint32: src)
        return AVVideoCodecType(rawValue: fourCC)
    }
    
    private func fourCC(uint32 src: UInt32) -> String {
        let c1 : UInt32 = (src >> 24) & 0xFF
        let c2 : UInt32 = (src >> 16) & 0xFF
        let c3 : UInt32 = (src >>  8) & 0xFF
        let c4 : UInt32 = (src      ) & 0xFF
        let bytes: [CChar] = [
            printable(uint32: c1, 0x20),
            printable(uint32: c2, 0x20),
            printable(uint32: c3, 0x20),
            printable(uint32: c4, 0x20),
            CChar(0x00)
        ]
        let fourCC: String = String(cString: bytes)
        return fourCC
    }
    
    private func printable(uint32 c: UInt32, _ placeholder: UInt32) -> CChar {
        let printable = (0x20 <= c && c <= 0x7e)
        return (printable ? CChar(c) : CChar(placeholder))
    }
    
    /* ======================================================================================== */
    //MARK: - AudioBitRateStrategy String/String conversion
    /* ======================================================================================== */
    
    /// Translate from AVAudioBitRateStrategy_* to tag
    /// - Parameter avAudioBitRateStrategy: AVAudioBitRateStrategy_*
    /// - Returns: UIString
    func bitRateStrategy(tagFor avAudioBitRateStrategy:String) -> Int {
        let dict = bitRateStrategyDictionary()
        if let tag = dict[avAudioBitRateStrategy] {
            return Int(tag)
        } else {
            return Int(dict[AVAudioBitRateStrategy_Constant]!)
        }
    }
    
    /// Translate from tag to AVAudioBitRateStrategy_*
    /// - Parameter uiString: UIString
    /// - Returns: AVAudioBitRateStrategy_*
    func bitRateStrategy(AVAudioFor tag:Int) -> String {
        let dict = bitRateStrategyDictionary()
        if let key = dict.first(where: { $0.value == UInt32(tag)})?.key {
            return key
        } else {
            return AVAudioBitRateStrategy_Constant
        }
    }
    
    /// Dictionary for AVAudioBitRateStrategy_* w/ kAudioCodecBitRateControlMode_*
    /// - Returns: Dictionary
    private func bitRateStrategyDictionary() -> [String:UInt32] {
        let dict = [
            AVAudioBitRateStrategy_Constant         : kAudioCodecBitRateControlMode_Constant,
            AVAudioBitRateStrategy_LongTermAverage  : kAudioCodecBitRateControlMode_LongTermAverage,
            AVAudioBitRateStrategy_VariableConstrained: kAudioCodecBitRateControlMode_VariableConstrained,
            AVAudioBitRateStrategy_Variable         : kAudioCodecBitRateControlMode_Variable,
        ]
        return dict
    }
    
}
