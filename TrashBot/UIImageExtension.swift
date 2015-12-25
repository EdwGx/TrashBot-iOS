//
//  UIImageExtension.swift
//  ImageFun
//
//  Created by Neeraj Kumar on 11/11/14.
//  Copyright (c) 2014 Neeraj Kumar. All rights reserved.
//

import Foundation
import UIKit

private extension UIImage {
    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
        
        //Get image width, height
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        //let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = UnsafeMutablePointer<UInt8>()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)!
        
        return context
    }
    
    func sanitizePoint(point:CGPoint) {
        let inImage:CGImageRef = self.CGImage!
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        precondition(CGRectContainsPoint(rect, point), "CGPoint passed is not inside the rect of image.It will give wrong pixel and may crash.")
    }
}


// Internal functions exposed.Can be public.

extension  UIImage {
    typealias RawColorType = (newRedColor:UInt8, newgreenColor:UInt8, newblueColor:UInt8,  newalphaValue:UInt8)
    
    
    /*
    Change the color of pixel at a certain point.If you want more control try block based method to modify pixels.
    */
    func setPixelColorAtPoint(point:CGPoint, color: RawColorType) -> UIImage? {
        self.sanitizePoint(point)
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        dataType[offset]   = color.newalphaValue
        dataType[offset+1] = color.newRedColor
        dataType[offset+2] = color.newgreenColor
        dataType[offset+3] = color.newblueColor
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)!
        return UIImage(CGImage: imageRef, scale: self.scale,orientation: self.imageOrientation)
        
    }
    
    
    /*
    Get pixel color for a pixel in the image.
    */
    func getPixelColorAtLocation(point:CGPoint)->UIColor? {
        self.sanitizePoint(point)
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
        let alphaValue = dataType[offset]
        let redColor = dataType[offset+1]
        let greenColor = dataType[offset+2]
        let blueColor = dataType[offset+3]
        
        let redFloat = CGFloat(redColor)/255.0
        let greenFloat = CGFloat(greenColor)/255.0
        let blueFloat = CGFloat(blueColor)/255.0
        let alphaFloat = CGFloat(alphaValue)/255.0
        
        return UIColor(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
        
        // When finished, release the context
        // Free image data memory for the context
    }
    
    
    // Get grayscale image from normal image.
    
    func getGrayScale() -> UIImage? {
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        for var x = 0; x < Int(pixelsWide) ; x++ {
            for var y = 0; y < Int(pixelsHigh) ; y++ {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let avg = (UInt32(red) + UInt32(green) + UInt32(blue))/3
                
                dataType[offset + 1] = UInt8(avg)
                dataType[offset + 2] = UInt8(avg)
                dataType[offset + 3] = UInt8(avg)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)!
        return UIImage(CGImage: imageRef, scale: self.scale,orientation: self.imageOrientation)
    }
    
    
    
    // Defining the closure.
    typealias ModifyPixelsClosure = (point:CGPoint, redColor:UInt8, greenColor:UInt8, blueColor:UInt8, alphaValue:UInt8)->(newRedColor:UInt8, newGreenColor:UInt8, newBlueColor:UInt8,  newAlphaValue:UInt8)
    
    
    // Provide closure which will return new color value for pixel using any condition you want inside the closure.
    
    func applyOnPixels(closure:ModifyPixelsClosure) -> UIImage? {
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        //let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        for var x = 0; x < Int(pixelsWide) ; x++ {
            for var y = 0; y < Int(pixelsHigh) ; y++ {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                let alpha = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let newValues = closure(point: CGPointMake(CGFloat(x), CGFloat(y)), redColor: red, greenColor: green,  blueColor: blue, alphaValue: alpha)
                
                dataType[offset] = newValues.newAlphaValue
                dataType[offset + 1] = newValues.newRedColor
                dataType[offset + 2] = newValues.newGreenColor
                dataType[offset + 3] = newValues.newBlueColor
                
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let finalcontext = CGBitmapContextCreate(data, pixelsWide, pixelsHigh, 8,  bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let imageRef = CGBitmapContextCreateImage(finalcontext)!
        return UIImage(CGImage: imageRef, scale: self.scale,orientation: self.imageOrientation)
    }
    
    func downsizeImageByScale(scale: Int) -> UIImage{
        let cgImage = self.CGImage!
        
        let width = CGImageGetWidth(cgImage) / scale
        let height = CGImageGetHeight(cgImage) / scale
        let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
        let bytesPerRow = CGImageGetBytesPerRow(cgImage)
        let colorSpace = CGImageGetColorSpace(cgImage)
        let bitmapInfo = CGImageGetBitmapInfo(cgImage)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        CGContextSetInterpolationQuality(context, .High)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), cgImage)
        
        return (CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0, scale: self.scale,orientation: self.imageOrientation) })!
    }
    
    func estimateRectForColor(color: UIColor, var maxDistance: Double) -> (center: CGPoint, xStd: CGFloat, yStd: CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)

        let tRed = Int(fRed * 255.0)
        let tGreen = Int(fGreen * 255.0)
        let tBlue = Int(fBlue * 255.0)
        
        maxDistance *= sqrt(pow(255.0,2.0)*3)
        maxDistance = pow(maxDistance,2.0)
        
        let inImage:CGImageRef = self.CGImage!
        let context = self.createARGBBitmapContext(inImage)
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        //Clear the context
        CGContextClearRect(context, rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(context, rect, inImage)
        
        var xArrays = [Double]()
        var yArrays = [Double]()
        var posCountI = 0
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafePointer<UInt8>(data)
        
        for var x = 0; x < Int(pixelsWide) ; x++ {
            for var y = 0; y < Int(pixelsHigh) ; y++ {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                
                var distance = 0.0
                distance += pow(Double(Int(dataType[offset+1]) - tRed),2.0)
                distance += pow(Double(Int(dataType[offset+2]) - tGreen),2.0)
                distance += pow(Double(Int(dataType[offset+3]) - tBlue),2.0)
                
                if distance < maxDistance {
                    xArrays.append(Double(x))
                    yArrays.append(Double(y))
                    posCountI += 1
                }
            }
        }
        
        if posCountI * 20 > pixelsWide * pixelsHigh {
            let posCount = Double(posCountI)
            
            let xAvg = xArrays.reduce(0.0, combine: +) / posCount
            let yAvg = yArrays.reduce(0.0, combine: +) / posCount
            
            var xStd = 0.0
            var yStd = 0.0
            
            for i in 0..<xArrays.count {
                xStd += pow((xArrays[i] - xAvg),2)
                yStd += pow((yArrays[i] - yAvg),2)
            }
            
            xStd /= posCount
            yStd /= posCount
            
            xStd = sqrt(xStd)
            yStd = sqrt(yStd)
            
            return (center: CGPointMake(CGFloat(xAvg), CGFloat(yAvg)), xStd: CGFloat(xStd), yStd: CGFloat(yStd))
        } else {
            return nil
        }
    }
    
    func imageByDrawingRectangle(rect: CGRect, tap: CGPoint, cen: CGPoint) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.drawAtPoint(CGPointZero)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetRGBStrokeColor(context, 255.0, 0.0, 0.0, 1.0)
        CGContextSetLineWidth(context, 5.0)
        
        let path = CGPathCreateWithRect(rect, nil)
        CGContextAddPath(context,path)
        CGContextStrokePath(context)
        
        CGContextSetRGBStrokeColor(context, 255.0, 255.0, 0, 1.0)
        CGContextSetRGBFillColor(context, 255.0, 255.0, 0.0, 1.0)
        CGContextSetLineWidth(context, 1.0)
        
        CGContextFillEllipseInRect(context, CGRect(x: tap.x - 5.0, y: tap.y - 5.0, width: 10.0, height: 10.0))
        
        CGContextFillEllipseInRect(context, CGRect(x: 100.0 - 5.0, y: 10.0 - 5.0, width: 10.0, height: 10.0))
        
        CGContextSetRGBStrokeColor(context, 255.0, 0.0, 255.0, 1.0)
        CGContextSetRGBFillColor(context, 255.0, 0.0, 255.0, 1.0)
        CGContextFillEllipseInRect(context, CGRect(x: cen.x - 5.0, y: cen.y - 5.0, width: 10.0, height: 10.0))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
}