//
//  ColorCaptureViewController.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class ColorCaptureViewController: UIViewController, CaptureVideoPreviewDelegate {
    var captureSession = AVCaptureSession()
    let preview = CaptureVideoPreview()
    let colorInforView = ColorInfoView(frame: CGRectZero)
    let stillImageOutput = AVCaptureStillImageOutput()
    let queue = NSOperationQueue()
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queue.name = "ColorCaptureViewController-Queue"
        queue.qualityOfService = .UserInitiated
        
        let navbarHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        var previewFrame = view.bounds
        previewFrame.size.height -= navbarHeight
        previewFrame.origin.y = navbarHeight
        preview.frame = previewFrame
        preview.backgroundColor = UIColor.blackColor()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.delegate = self
        self.view.addSubview(preview)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-navbarHeight-[view]-0-|", options: [], metrics: ["navbarHeight":navbarHeight], views: ["view":preview]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view":preview]))
        
        imageView.hidden = true
        imageView.contentMode = .ScaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-navbarHeight-[view]-0-|", options: [], metrics: ["navbarHeight":navbarHeight], views: ["view":imageView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view":imageView]))
        
        colorInforView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(colorInforView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==44)]-0-|", options: [], metrics: nil, views: ["view":colorInforView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view":colorInforView]))
        
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            (granted: Bool) -> Void in
            // If permission hasn't been granted, notify the user.
            if granted {
                dispatch_async(dispatch_get_main_queue(), {
                    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                    
                    do {
                        let input = try AVCaptureDeviceInput(device: captureDevice)
                        
                        self.captureSession = AVCaptureSession()
                        self.captureSession.addInput(input as AVCaptureDeviceInput)
                        
                        self.preview.captureSession = self.captureSession
                        
                        self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                        if self.captureSession.canAddOutput(self.stillImageOutput) {
                            self.captureSession.addOutput(self.stillImageOutput)
                        }
                        
                        self.captureSession.startRunning()
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
    
    func captureColorInCaptureDevicePointOfInterest(point: CGPoint) {
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {[weak self] (imageDataSampleBuffer, error) -> Void in
            if (imageDataSampleBuffer != nil && error == nil) {
                let imageData: NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                if let image: UIImage = UIImage(data: imageData){
                    self?.receiveImage(image, pointOfInterest: point)
                }
            }
        })
    }
    
    func receiveImage(rawImage: UIImage, pointOfInterest: CGPoint) {
        let image = rawImage.downsizeImageByScale(4)
        let downSizedImage = image.downsizeImageByScale(2)
        
        let x = image.size.width * (1.0 - pointOfInterest.y)
        let y = image.size.height * pointOfInterest.x
        
        let pX = image.size.height * pointOfInterest.x
        let pY = image.size.width * pointOfInterest.y
        
        let color = image.getPixelColorAtLocation(CGPointMake(pX,pY))
        
        let labeledImage: UIImage
        if let objectRect = downSizedImage.estimateRectForColor(color!, maxDistance: 0.14) {
            let gY = objectRect.center.x * image.size.height / downSizedImage.size.height
            let gX = image.size.width - (objectRect.center.y * image.size.width / downSizedImage.size.width)
            
            var trueRect = CGRectZero
            trueRect.size.height = objectRect.xStd * image.size.height / downSizedImage.size.height * 2
            trueRect.size.width = objectRect.yStd * image.size.width / downSizedImage.size.width * 2
            
            trueRect.origin.x = gX - trueRect.size.width/2
            trueRect.origin.y = gY - trueRect.size.height/2
            
            
            
            labeledImage = image.imageByDrawingRectangle(trueRect, tap: CGPoint(x: x, y: y), cen: CGPoint(x: gX, y: gY))
        } else {
            labeledImage = image
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.colorInforView.color = color
            self.imageView.hidden = false
            self.imageView.image = labeledImage
            self.preview.hidden = true
            self.captureSession.stopRunning()
        }
    }
}
