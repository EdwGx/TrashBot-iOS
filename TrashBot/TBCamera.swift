//
//  TBCamera.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-25.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation

class TBCamera: NSObject {
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    
    var capturedImage: UIImage?
    
    var didSetup = false
    
    var authorized = false
    
    static let sharedCamera = TBCamera()
    
    func setup() {
        authorized = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized
        if (authorized && !didSetup) {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                
                do {
                    let input = try AVCaptureDeviceInput(device: captureDevice)
                    self.captureSession.addInput(input as AVCaptureDeviceInput)
                    
                    self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                    
                    if self.captureSession.canAddOutput(self.stillImageOutput) {
                        self.captureSession.addOutput(self.stillImageOutput)
                    }
                } catch {
                    NSLog("\(error)")
                }
            })
            self.captureSession.startRunning()
            didSetup = true
        }
    }
    
    func captureColorObject(hex: String) -> CGRect? {
        if (authorized) {
            let sem: dispatch_semaphore_t = dispatch_semaphore_create(0)
            
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {[weak self] (imageDataSampleBuffer, error) -> Void in
                if (imageDataSampleBuffer != nil && error == nil) {
                    let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                    self?.capturedImage = UIImage(data: imageData)
                }
                dispatch_semaphore_signal(sem)
            })
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
            
            if self.capturedImage != nil {
                let downSizedImage = self.capturedImage!.downsizeImageByScale(8)
                return downSizedImage.estimateRelativePositionForColor(UIColor(hexString: hex), maxDistance: 200.0)
            }
        }
        return nil
    }
    
    func stopSession() {
        if self.captureSession.running {
            self.captureSession.stopRunning()
        }
    }
}