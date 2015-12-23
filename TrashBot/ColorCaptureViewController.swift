//
//  ColorCaptureViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

class ColorCaptureViewController: UIViewController {
    var captureSession: AVCaptureSession?
    let preview = CaptureVideoPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview.frame = view.bounds
        self.view.addSubview(preview)
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            (granted: Bool) -> Void in
            // If permission hasn't been granted, notify the user.
            if granted {
                dispatch_async(dispatch_get_main_queue(), {
                    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                    
                    do {
                        let input = try AVCaptureDeviceInput(device: captureDevice)
                        
                        self.captureSession = AVCaptureSession()
                        self.captureSession?.addInput(input as AVCaptureDeviceInput)
                        
                        self.preview.captureSession = self.captureSession
                        
                        self.captureSession?.startRunning()
                    } catch {
                        
                    }
                })
            }
        });
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
