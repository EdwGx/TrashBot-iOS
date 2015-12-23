//
//  CaptureVideoPreview.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureVideoPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
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
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        previewLayer?.frame = self.bounds
    }
}
