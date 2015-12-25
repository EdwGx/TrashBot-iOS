//
//  CaptureVideoPreview.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

protocol CaptureVideoPreviewDelegate {
    func captureColorInCaptureDevicePointOfInterest(point: CGPoint)
}

class CaptureVideoPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var delegate: CaptureVideoPreviewDelegate?
    
    var captureSession: AVCaptureSession? {
        didSet {
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer!.frame = self.bounds
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.layer.addSublayer(previewLayer!)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        let touch = touches.first!
        let position = previewLayer?.captureDevicePointOfInterestForPoint(touch.locationInView(self))
        self.delegate?.captureColorInCaptureDevicePointOfInterest(position!)
    }
}
