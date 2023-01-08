//
//  AppDelegate+Layout.swift
//  recdv2
//
//  Created by Takashi Mochizuki on 2022/12/22.
//  Copyright © 2022 MyCometG3. All rights reserved.
//

/* This software is released under the MIT License, see LICENSE.txt. */

import Cocoa
import AVFoundation

extension AppDelegate: NSWindowDelegate, CALayerDelegate, CALayoutManager {
    
    /* ======================================================================================== */
    // MARK: - NSWindowDelegate protocol
    /* ======================================================================================== */
    
    func windowDidResize(_ notification: Notification) {
        // print("\(#file) \(#line) \(#function)")
        if let layer = self.parentView.layer  {
            layoutSublayers(of: layer)
        }
    }
    
    /* ======================================================================================== */
    // MARK: - Scaling support
    /* ======================================================================================== */
    
    func setScale(_ scaleTag: Int) {
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
    
    /* ======================================================================================== */
    // MARK: - AspectRatio support
    /* ======================================================================================== */
    
    func setAspectRatio(_ ratioTag: Int) {
        // print("\(#file) \(#line) \(#function)")
        
        defaults.set(ratioTag, forKey: Keys.aspectRatio)
        
        resizeAspect()
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
    
    func checkOnActiveSpace() {
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
    
    func removePreviewLayer() {
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
