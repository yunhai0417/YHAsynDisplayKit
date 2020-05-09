//
//  UIImage+YHAsynGraver.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/5.
//  Copyright © 2020 YH. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import CoreText
import CoreGraphics
import Foundation
import Accelerate
/**
YHAsyncCornerRadius
定义圆角的左上，右上，左下，右下四个位置的圆角半径值
*/

public struct YHAsyncCornerRadius {
    var topLeft:CGFloat = 0
    var topRight:CGFloat = 0
    var bottomLeft:CGFloat = 0
    var bottomRight:CGFloat = 0
}

/**
创建一个YHAsyncCornerRadius，指定不同位置的圆角半径
@param topLeft     左上位置的圆角半径
@param topRight    右上位置的圆角半径
@param bottomLeft  左下位置的圆角半径
@param bottomRight 右下位置的圆角半径
@return 返回WMGCornerRadius，指定不同位置的圆角半径
*/

public func YHAsyncCornerRadiusMake(inTopLeft topLeft:CGFloat, inTopRight topRight:CGFloat, inBottomLeft bottomLeft:CGFloat, inBottomRight bottomRight:CGFloat) -> YHAsyncCornerRadius {
    let radius = YHAsyncCornerRadius.init(topLeft: topLeft,
                                          topRight: topRight,
                                          bottomLeft: bottomLeft,
                                          bottomRight: bottomRight)
    return radius
}

public func YHAsyncCornerRadiusEqual(inR r1:YHAsyncCornerRadius, inL r2:YHAsyncCornerRadius ) -> Bool {
    return r1.topLeft == r2.topLeft && r1.topRight == r2.topRight && r1.bottomLeft == r2.bottomLeft && r1.bottomRight == r2.bottomRight
}

public func YHAsyncCornerRadiusIsPerfect(_ radius:YHAsyncCornerRadius) -> Bool {
    return radius.topLeft == radius.topRight
        && radius.bottomLeft == radius.bottomRight
        && radius.topLeft == radius.bottomLeft
}

public func YHAsyncCornerRadiusPerfectRadius(_ r:CGFloat) -> YHAsyncCornerRadius {
    return YHAsyncCornerRadius.init(topLeft: r, topRight: r, bottomLeft: r, bottomRight: r)
}

//判断倒角结构体内容数据是否正确可用
public func YHAsyncCornerRadiusIsValid(_ r:YHAsyncCornerRadius) -> Bool {
    return r.topLeft > 0.0 || r.topRight > 0.0 || r.bottomLeft > 0.0 || r.bottomRight > 0.0
}

let YHAsyncCornerRadiusZero = YHAsyncCornerRadius.init()

extension UIImage {
    
    /**
    * 圆角处理
    *
    * @param radius 指定圆角弧度
    *
    * @return UIImage
    */
    
    public func yh_roundedImageWithRadius(_ radius:CGFloat) -> UIImage? {
        if self.size.height == 0 || self.size.width == 0 {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        // Add a clip before drawing anything, in the shape of an rounded rect
        UIBezierPath.init(roundedRect: rect, cornerRadius: radius).addClip()
        // Draw your image
        self.draw(in: rect)
        // Get the image, here setting the UIImageView image
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /**
    * 圆角图片创建
    *
    * @param size  大小
    * @param color 颜色
    * @param radius  圆角
    *
    * @return UIImage
    */
    
    public class func yh_roundedImageWithSize(_ size:CGSize, inColor color:UIColor, inRadius radius:CGFloat) -> UIImage? {
        let newRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height).integral
        // Build a context that's the same dimensions as the new size
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        let bitmap:CGContext? = CGContext.init(data: nil,
                                               width: Int(newRect.size.width),
                                               height: Int(newRect.size.height),
                                               bitsPerComponent: 8,
                                               bytesPerRow: Int(newRect.size.width) * 4,
                                               space: rgbColorSpace,
                                               bitmapInfo: bmpInfo.rawValue)
        // Default white background color.
        let rect = CGRect.init(x: 0, y: 0, width: newRect.size.width, height: newRect.size.height)
        let clippath = UIBezierPath.init(roundedRect: rect, cornerRadius: radius).cgPath
        bitmap?.addPath(clippath)
        bitmap?.clip()
        
        bitmap?.setFillColor(color.cgColor)
        bitmap?.fill(rect)
        // Get the resized image from the context and a UIImage
        
        if let newCGImage = bitmap?.makeImage() {
            return UIImage.init(cgImage: newCGImage)
        }
        
        return nil
    }
    
    /**
    * 创建一张纯色图片
    *
    * @param color         图片颜色
    * @return UIImage
    */
   public class func imageCreateWithColor(_ color:UIColor) -> UIImage? {
        
        return self.imageCreateWithColor(color, inSize: CGSize.init(width: 1, height: 1))
    }
    
    /**
    * 创建一张图片
    *
    * @param color         图片颜色
    * @param size          图片size
    *
    * @return UIImage
    */
    
    public class func imageCreateWithColor(_ color:UIColor, inSize size:CGSize) -> UIImage? {
        return self.imageCreateWithColor(color, inSize: size, borderWidth: 0, inBorderColor: nil, cornerRadius: 0)
    }
    
    /**
    * 创建一张图片
    *
    * @param color         图片颜色
    * @param size          图片size
    * @param width         border宽度
    * @param borderColor   border颜色
    * @param radius        圆角半径 CGFloat
    *
    * @discussion          该方法可以创建一站矩形纯色图片，带边框、带圆角、底色透明，边框带线条的各种样式
    *
    * @return UIImage
    */
    
    public class func imageCreateWithColor(_ color:UIColor, inSize size:CGSize, borderWidth width:CGFloat, inBorderColor borderColor:UIColor?, cornerRadius radius:CGFloat) -> UIImage? {
        
        return self.imageCreateWithColor(color, inSize: size, borderWidth: width, inBorderColor: borderColor, cornerRadius: YHAsyncCornerRadiusPerfectRadius(radius))
    }
    
    /**
    * 创建一张图片
    *
    * @param color         图片颜色
    * @param size          图片size
    * @param width         border宽度
    * @param borderColor   border颜色
    * @param radius        圆角半径 WMGCornerRadius
    *
    * @discussion          根据WMGCornerRadius结构体可以指定任一一个角的弧度，也可指定每个角都有不同的弧度
    * @return UIImage
    */
    public class func imageCreateWithColor(_ color:UIColor, inSize size:CGSize, borderWidth width:CGFloat, inBorderColor borderColor:UIColor?, cornerRadius radius:YHAsyncCornerRadius) -> UIImage? {
        
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil}
        
        if !YHAsyncCornerRadiusIsValid(radius) {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
            if width > 0 {
                var path = UIBezierPath.init(rect: rect)
                context.addPath(path.cgPath)
                if let borderColor = borderColor {
                    context.setStrokeColor(borderColor.cgColor)
                }
                context.setLineWidth(width)
                context.drawPath(using: CGPathDrawingMode.fillStroke)
            }
        } else {
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(rect)
            var path:UIBezierPath = UIBezierPath.bezierPathCreateWithRect(rect, cornerRadius: radius, lineWidth: width)
            path.usesEvenOddFillRule = true
            path.addClip()
            
            context.addPath(path.cgPath)
            
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
            context.addPath(path.cgPath)
            
            if width > 0.0 {
                if let borderColor = borderColor {
                    context.setStrokeColor(borderColor.cgColor)
                }
                context.setLineWidth(width)
                context.drawPath(using: CGPathDrawingMode.fillStroke)
            } else {
                context.drawPath(using: CGPathDrawingMode.fill)
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /**
    * 将一张图片绘制到另一张图片的指定位置
    *
    * @param image         图片
    * @param point         指定绘制位置
    *
    * @return UIImage
    */
    public func yh_drawImage(_ image:UIImage, atPosition point:CGPoint) -> UIImage? {
        if self.size.height == 0 || self.size.width == 0 {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let rect = CGRect.init(x: point.x, y: point.y, width: self.size.width, height: self.size.height )
        
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /**
    * 将一个AttributedItem绘制到一张图片的指定位置
    *
    * @param item         WMMutableAttributedItem
    * @param point        指定绘制位置
    *
    * @return UIImage
    */
    
    public func yh_drawItem(_ item:YHAsyncMutableAttributedItem, atPosition point:CGPoint) -> UIImage? {
        if self.size.height == 0 || self.size.width == 0 {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let rect = CGRect.init(x: point.x, y: point.y, width: self.size.width - point.x, height: self.size.height - point.y)
        
        item.resultString?.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /**
    * 将一个AttributedItem绘制到一张图片的指定位置
    *
    * @param item          WMMutableAttributedItem
    * @param numberOfLines 可指定按几行绘制
    * @param point         指定绘制位置
    *
    * @return UIImage
    */
    
    public func yh_drawItem(_ item:YHAsyncMutableAttributedItem, numberOfLines lines:NSInteger, atPosition point:CGPoint) -> UIImage? {
        if self.size.height == 0 || self.size.width == 0 {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let rect = CGRect.init(x: point.x, y: point.y, width: self.size.width - point.x, height: self.size.height - point.y)
        
        item.resultString?.yh_drawInRect(rect, numberOflines: lines, context: UIGraphicsGetCurrentContext())
        
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /** Fix
    * 图片模糊处理 //TODO 有问题颜色变蓝
    * @param percent  非法值按照0.5模糊处理 percent : 0.0 ~ 1.0
    * @return UIImage
    */
    
    public func yh_blurImageWithBlurPercent(_ percet:CGFloat) -> UIImage? {
        
        guard let imageData = self.jpegData(compressionQuality: 1) else { return self }
        guard let destImage = UIImage.init(data: imageData) else { return self }
        
        var newPercent:CGFloat = percet
        if percet < 0.0 || percet > 1.0 {
            newPercent = 0.5;
        }
        var boxSize:Int = Int(newPercent * 40)
        boxSize = boxSize - boxSize % 2 + 1
        
        guard let imgRef = destImage.cgImage else { return self }
        
        var inBuffer = vImage_Buffer()
        var outBuffer = vImage_Buffer()
        var error: vImage_Error?
        var pixelBuffer: UnsafeMutableRawPointer!
        
        // 从CGImage中获取数据
        let inProvider = imgRef.dataProvider
        let inBitmapData:CFData? = inProvider?.data
        
        // 设置从CGImage获取对象的属性
        inBuffer.width = vImagePixelCount(imgRef.width)
        inBuffer.height = vImagePixelCount(imgRef.height)
        inBuffer.rowBytes = imgRef.bytesPerRow
        inBuffer.data = UnsafeMutableRawPointer.init(mutating:CFDataGetBytePtr(inBitmapData!))
        
        //create vImage_Buffer for output
        
        pixelBuffer = UnsafeMutableRawPointer.allocate(byteCount: imgRef.bytesPerRow * imgRef.height, alignment: 0)
        if pixelBuffer == nil {
            NSLog("No pixel buffer!")
        }

        outBuffer.data = pixelBuffer
        outBuffer.width = vImagePixelCount(imgRef.width)
        outBuffer.height = vImagePixelCount(imgRef.height)
        outBuffer.rowBytes = imgRef.bytesPerRow
        
        var pixelBuffer2: UnsafeMutableRawPointer!
        var outBuffer2 = vImage_Buffer()
        pixelBuffer2 = UnsafeMutableRawPointer.allocate(byteCount: imgRef.bytesPerRow * imgRef.height, alignment: 0)
        if pixelBuffer2 == nil {
            NSLog("No pixel buffer!")
        }

        outBuffer2.data = pixelBuffer
        outBuffer2.width = vImagePixelCount(imgRef.width)
        outBuffer2.height = vImagePixelCount(imgRef.height)
        outBuffer2.rowBytes = imgRef.bytesPerRow
        
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, UInt32(kvImageEdgeExtend))

        if error != nil {
            print("error from convolution \(error)")
        }
        
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, UInt32(kvImageEdgeExtend))

        if error != nil {
            print("error from convolution \(error)")
        }
        
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, UInt32(boxSize), UInt32(boxSize), nil, UInt32(kvImageEdgeExtend))

        if error != nil {
            print("error from convolution \(error)")
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        let bitmap:CGContext? = CGContext.init(data: outBuffer.data,
                                               width: Int(outBuffer.width),
                                               height: Int(outBuffer.height),
                                               bitsPerComponent: 8,
                                               bytesPerRow: outBuffer.rowBytes,
                                               space: colorSpace,
                                               bitmapInfo: bmpInfo.rawValue)
        
        if let imageRef = bitmap?.makeImage() {
            let returnImage = UIImage(cgImage: imageRef)
            //clean up
            pixelBuffer.deallocate()
            return returnImage
        }
        return nil
    }
    
    /**
    * 图片灰化处理
    *
    * @return UIImage
    */
     
    public func yh_greyImage() -> UIImage? {
        let scale = self.scale
        let size = self.size
        let width = Int(size.width * scale)
        let height = Int(size.height * scale)
        
        // 申请内存空间
        let pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: Int(width * height) )
        //UInt32在计算机中所占的字节
        let uint32Size = MemoryLayout<UInt32>.size
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        
        let context:CGContext? = CGContext.init(data: pixels,
                                                width: width,
                                                height: height,
                                                bitsPerComponent: 8,
                                                bytesPerRow: width * uint32Size,
                                                space: colorSpace,
                                                bitmapInfo: bmpInfo.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let rgbaPixel = pixels.advanced(by: y * width + x)
                //类型转换 -> UInt8
                let rgb = unsafeBitCast(rgbaPixel, to: UnsafeMutablePointer<UInt8>.self)
                // rgba 所在位置 alpha 0, blue  1, green 2, red 3
                let gray = UInt8(0.3  * Double(rgb[3]) +
                                 0.59 * Double(rgb[2]) +
                                 0.11 * Double(rgb[1]))
                rgb[3] = gray
                rgb[2] = gray
                rgb[1] = gray
            }
        }
        
        guard let image = context?.makeImage() else {
            return nil
        }
        
        pixels.deallocate()
        
        return UIImage(cgImage: image, scale: scale, orientation: UIImage.Orientation.up)
    }
    
    
    
    /**
    * 圆角处理
    *
    * @return UIImage
    */
    
    public func yh_roundedImage() -> UIImage? {
        let scale = self.scale
        let width = Int(self.size.width )
        let height = Int(self.size.height )
        
        var image:UIImage?
        
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        UIBezierPath.init(rect: rect).addClip()
        
        self.draw(in: rect)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    
    /**
    * 圆角处理
    *
    * @param cornerRadius    指定圆角弧度
    * @param rectCornerType  指定圆角位置
    *
    * @return UIImage
    */
    
    public func yh_roundedImageWithRadius(_ radius:CGFloat, rectCornerType cornerType:UIRectCorner) -> UIImage? {
        let scale = self.scale
        let width = self.size.width
        let height = self.size.height
        
        var cornerRadius = max(0, min(min(width, height)/2, radius))
        
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        UIBezierPath.init(roundedRect: rect, byRoundingCorners: cornerType, cornerRadii: CGSize.init(width: cornerRadius, height: cornerRadius)).addClip()
        
        self.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
    * 圆角处理
    *
    * @param radius    WMGCornerRadius类型指定圆角弧度
    *
    * @return UIImage
    */
    
    public func yh_roundedImageWithCornerRadius(_ radius:YHAsyncCornerRadius) -> UIImage? {
        if !YHAsyncCornerRadiusIsValid(radius) {
            return self
        }
        
        let scale = self.scale
        let width = self.size.width
        let height = self.size.height
        
        let rect = CGRect.init(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.topLeft, cornerRadii: CGSize.init(width: radius.topLeft, height: radius.topLeft)).addClip()
        
        UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.topRight, cornerRadii: CGSize.init(width: radius.topRight, height: radius.topRight)).addClip()
        
        UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.bottomLeft, cornerRadii: CGSize.init(width: radius.bottomLeft, height: radius.bottomLeft)).addClip()
        
        UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.bottomRight, cornerRadii: CGSize.init(width: radius.bottomRight, height: radius.bottomRight)).addClip()
        self.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**
    * 获取一张 图片的缩略图
    *
    * @param thumbnailSize    缩略图size
    * @param borderSize       边框size
    * @param cornerRadius     圆角
    * @param contentMode      内容模式
    * @param quality          质量参数
    *
    * @return UIImage
    */
    
    public func yh_thumbnailImage(_ thumbnailSize:NSInteger, transparentBorder borderSize:NSInteger, inCornerRadius cornerRadius:NSInteger, resizeMode contentMode:UIView.ContentMode, interpolationQuality quality:CGInterpolationQuality) -> UIImage? {
        let thumbnailSize1:CGFloat = CGFloat(thumbnailSize)
        var resizedImage = self.yh_resizedImageWithContentMode(contentMode,
                                                               inBounds: CGSize.init(width: thumbnailSize, height: thumbnailSize),
                                                               interpolationQuality: quality)
        
        guard let resizedImage1 = resizedImage else { return nil}
        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        
        let cropRect = CGRect.init(x: round((resizedImage1.size.width - thumbnailSize1) / 2),
                                   y: round((resizedImage1.size.height - thumbnailSize1) / 2),
                                   width: thumbnailSize1,
                                   height: thumbnailSize1)
        
        let cropedImage = resizedImage1.yh_croppedImage(cropRect)
        
        let transparentBorderImage = borderSize > 0 ? cropedImage?.yh_transparentBorderImage(UInt(borderSize)) : cropedImage
        
        
        
        return transparentBorderImage?.yh_roundedCornerImage(cornerRadius, inBorderSize: borderSize)
    }
    
    // Resizes the image according to the given content mode, taking into account the image's orientation
    public func yh_resizedImageWithContentMode(_ contentMode:UIView.ContentMode, inBounds bounds:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage? {
        let horizontalRatio:CGFloat = bounds.width / self.size.width
        let verticalRatio:CGFloat = bounds.height / self.size.height
        var ratio:CGFloat = 0
        var newSize:CGSize = CGSize.zero
        
        if contentMode == UIView.ContentMode.scaleAspectFill {
            ratio = max(horizontalRatio, verticalRatio)
            let w = CGFloat(roundf(Float(self.size.width * ratio)))
            let h = CGFloat(roundf(Float(self.size.height * ratio)))
            newSize = CGSize.init(width: w, height: h)
        } else if contentMode == UIView.ContentMode.scaleAspectFit {
            ratio = min(horizontalRatio, verticalRatio)
            let w = CGFloat(roundf(Float(self.size.width * ratio)))
            let h = CGFloat(roundf(Float(self.size.height * ratio)))
            newSize = CGSize.init(width: w, height: h)
        } else if contentMode == UIView.ContentMode.scaleToFill {
            let w = CGFloat(roundf(Float(self.size.width * horizontalRatio)))
            let h = CGFloat(roundf(Float(self.size.height * verticalRatio)))
            newSize = CGSize.init(width: w, height: h)
        } else {
            return self
        }
        
        return self.yh_resizedImage(newSize, interpolationQuality: quality)
    }
    
    public func yh_resizedImage(_ newSize:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage? {
        var drawTransposed:Bool = false
        let orientation = self.imageOrientation
        if orientation == UIImage.Orientation.left || orientation == UIImage.Orientation.leftMirrored || orientation == UIImage.Orientation.right || orientation == UIImage.Orientation.rightMirrored {
            drawTransposed = true
        }
        
        return self.yh_resizedImage(newSize,
                                    intransform: self.yh_transformForOrientation(newSize),
                                    drawTransposed: drawTransposed,
                                    interpolationQuality: quality)
    }
    
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
    public func yh_resizedImage(_ newSize:CGSize, intransform transform:CGAffineTransform, drawTransposed transpose:Bool, interpolationQuality quality:CGInterpolationQuality) -> UIImage? {
        let newRect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        let transposedRect = CGRect.init(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        
        guard let imageRef = self.cgImage else {
            return nil
        }
        
        // Build a context that's the same dimensions as the new size
        let bitmapInfo = CGBitmapInfo.init(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context:CGContext? = CGContext.init(data: nil,
                                                width: Int(newRect.size.width),
                                                height: Int(newRect.size.height),
                                                bitsPerComponent: 8,
                                                bytesPerRow: Int(newRect.size.width * 4),
                                                space: rgbColorSpace,
                                                bitmapInfo: bitmapInfo.rawValue)
        
        // Default white background color.
        let rect = CGRect.init(x: 0, y: 0, width: newRect.size.width, height: newRect.size.height)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        
        // Rotate and/or flip the image if required by its orientation
        context?.concatenate(transform)
        
        // Draw into the context; this scales the image
        context?.draw(imageRef, in: transpose ? transposedRect : newRect)
        
        // Get the resized image from the context and a UIImage

        if let newImageRef = context?.makeImage() {
            return UIImage.init(cgImage: newImageRef)
        }
        return nil
    }

    
    
    /**
    * 图片裁剪
    *
    * @param croppedSize      裁剪size
    * @param contentMode      内容模式
    * @param quality          质量参数
    *
    * @return UIImage
    */
    
    public func yh_cropImageWithCroppedSize(_ croppedSize:CGSize, resizeMode contentMode:UIView.ContentMode, interpolationQuality quality:CGInterpolationQuality) -> UIImage? {
        guard let resizedImage = self.yh_resizedImageWithContentMode(contentMode, inBounds: croppedSize, interpolationQuality: quality) else { return nil
        }
        
        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        
        let x = CGFloat(roundf(Float(resizedImage.size.width - croppedSize.width) / 2))
        let y = CGFloat(roundf(Float(resizedImage.size.height - croppedSize.height) / 2))
        let cropRect = CGRect.init(x: x, y: y, width: croppedSize.width, height: croppedSize.height)
        
        return resizedImage.yh_croppedImage(cropRect)
    }
    
    /**
    * 将一张图片调整到指定size，生成一张新图片
    *
    * @param size      size
    *
    * @return UIImage
    */
    
    public func yh_resizedImageToSize(_ size:CGSize) -> UIImage? {
        guard let imgRef = self.cgImage else { return nil }
        // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
        // not equivalent to self.size (which is dependant on the imageOrientation)!
        let srcSize = CGSize.init(width: imgRef.width, height: imgRef.height)
        var newSize:CGSize = size
        /* Don't resize if we already meet the required destination size. */
        if size.equalTo(srcSize) {
            return self
        }
        
        let scaleRatio:CGFloat = size.width / srcSize.width
        let orient = self.imageOrientation
        var transform = CGAffineTransform.identity
        
        switch orient {
        case UIImage.Orientation.up:
            transform = CGAffineTransform.identity
            
        case UIImage.Orientation.upMirrored:
            transform = CGAffineTransform.init(translationX: srcSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            
        case UIImage.Orientation.down:
            transform = CGAffineTransform.init(translationX: srcSize.width, y: srcSize.height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case UIImage.Orientation.downMirrored:
            transform = CGAffineTransform.init(translationX: 0.0, y: srcSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            
        case UIImage.Orientation.left:
            newSize = CGSize.init(width: newSize.height, height: newSize.width)
            transform = CGAffineTransform.init(translationX: 0.0, y: srcSize.width)
            transform = transform.rotated(by: CGFloat.pi * 3.0)
        
        case UIImage.Orientation.leftMirrored:
            newSize = CGSize.init(width: newSize.height, height: newSize.width)
            transform = CGAffineTransform.init(translationX: srcSize.height, y: srcSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat.pi * 3.0)
            
        case UIImage.Orientation.right:
            newSize = CGSize.init(width: newSize.height, height: newSize.width)
            transform = CGAffineTransform.init(translationX: srcSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat.pi * 0.5 )
        
        case UIImage.Orientation.rightMirrored:
            newSize = CGSize.init(width: newSize.height, height: newSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat.pi * 0.5)
            
        default:
            transform = CGAffineTransform.identity
            NSException.init(name: NSExceptionName.internalInconsistencyException, reason: "Invalid image orientation", userInfo: nil)
        }
        
        /////////////////////////////////////////////////////////////////////////////
        // The actual resize: draw the image on a new context, applying a transform matrix
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        guard let context:CGContext = UIGraphicsGetCurrentContext() else { return nil }
        
        if orient == UIImage.Orientation.right || orient == UIImage.Orientation.left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -srcSize.height, y: 0)
        } else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: -srcSize.height)
        }
        
        context.concatenate(transform)
        // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
        
        let ctx:CGContext? = UIGraphicsGetCurrentContext()
        ctx?.draw(imgRef, in: CGRect.init(x: 0, y: 0, width: srcSize.width, height: srcSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension UIImage {
    
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    fileprivate func yh_croppedImage(_ bounds:CGRect) -> UIImage? {
        let newBounds = CGRect.init(x: bounds.origin.x * self.scale,
                                    y: bounds.origin.y * self.scale,
                                    width: bounds.size.width * self.scale,
                                    height: bounds.size.height * self.scale)
        
        if let cgimag = self.cgImage?.cropping(to: bounds) {
            let croppedImage = UIImage.init(cgImage: cgimag, scale: self.scale, orientation: self.imageOrientation)
            return croppedImage
        }
        return nil
    }
    
    // Returns a copy of the image with a transparent border of the given size added around its edges.
    // If the image has no alpha layer, one will be added to it.
    func yh_transparentBorderImage(_ borderSize:UInt) -> UIImage? {
        // If the image does not have an alpha layer, add one
        guard let image = self.yh_imageWithAlpha() else { return nil }
        let newRect = CGRect.init(x: 0, y: 0,
                                  width: image.size.width + CGFloat(borderSize * 2),
                                  height: image.size.height + CGFloat(borderSize * 2))
        // Build a context that's the same dimensions as the new size
        guard let cgImg = self.cgImage else { return nil}
        guard let colorSpace = cgImg.colorSpace else { return nil }
        let context:CGContext? = CGContext.init(data: nil,
                                                width: Int(newRect.size.width),
                                                height: Int(newRect.size.height),
                                                bitsPerComponent: cgImg.bitsPerComponent,
                                                bytesPerRow: 0,
                                                space:colorSpace ,
                                                bitmapInfo: cgImg.bitmapInfo.rawValue)
        
        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation = CGRect.init(x: CGFloat(borderSize), y: CGFloat(borderSize), width: image.size.width, height:image.size.height )
        context?.draw(cgImg, in: imageLocation)
        
        let borderImageRef = context?.makeImage()
        
        // Create a mask to make the border transparent, and combine it with the image
        if let maskImageRef = self.yh_newBorderMask(borderSize, inSize: newRect.size) {
            if let transparentBorderImageRef = borderImageRef?.masking(maskImageRef) {
                return UIImage.init(cgImage: transparentBorderImageRef)
            }
        }
        
        return nil
    }
    
    // Returns a copy of the given image, adding an alpha channel if it doesn't already have one
    fileprivate func yh_imageWithAlpha() -> UIImage? {
        if self.yh_hasAlpha() {
            return self
        }
        guard let cgImg = self.cgImage else { return nil }
        let width = cgImg.width
        let height = cgImg.height
        
        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        guard let colorSpace = cgImg.colorSpace else { return nil }
        
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        let context:CGContext? = CGContext.init(data: nil,
                                                width: width,
                                                height: height,
                                                bitsPerComponent: 8,
                                                bytesPerRow: 0,
                                                space: colorSpace,
                                                bitmapInfo: bmpInfo.rawValue)
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        context?.draw(cgImg, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        if let imageRefWithAlpha = context?.makeImage() {
            let imageWithAlpha = UIImage.init(cgImage: imageRefWithAlpha)
//            CGImageRelease(imageRefWithAlpha)
//            CGContextRelease(context!)
            return imageWithAlpha
        }
        return nil
    }
    
    // Returns true if the image has an alpha layer
    public func yh_hasAlpha() -> Bool {
        
        if let alpha = self.cgImage?.alphaInfo {
            let result = alpha == CGImageAlphaInfo.first || alpha == CGImageAlphaInfo.last || alpha == CGImageAlphaInfo.premultipliedFirst || alpha == CGImageAlphaInfo.premultipliedLast
            return result
        }
        
        return false
    }
    
    // Creates a mask that makes the outer edges transparent and everything else opaque
    // The size must include the entire mask (opaque part + transparent border)
    // The caller is responsible for releasing the returned reference by calling CGImageRelease
    
    func yh_newBorderMask(_ borderSize:UInt, inSize size:CGSize) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bmpInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue )
        // Build a context that's the same dimensions as the new size
        let context:CGContext? = CGContext.init(data: nil,
                                                width: Int(size.width),
                                                height: Int(size.height),
                                                bitsPerComponent: 8, // 8-bit grayscale
                                                bytesPerRow: 0,
                                                space: colorSpace,
                                                bitmapInfo: bmpInfo.rawValue)

        // Start with a mask that's entirely transparent
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        // Make the inner part (within the border) opaque
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect.init(x: CGFloat(borderSize), y: CGFloat(borderSize), width: size.width - CGFloat(borderSize * 2) , height: size.height - CGFloat(borderSize * 2)))
        
        return context?.makeImage()
    }
    
    // Creates a copy of this image with rounded corners
    // If borderSize is non-zero, a transparent border of the given size will also be added
    func yh_roundedCornerImage(_ cornerSize:NSInteger, inBorderSize bordersize:NSInteger) -> UIImage? {
        // If the image does not have an alpha layer, add one
        guard let image = self.yh_imageWithAlpha() else { return nil}
        guard let cgImg = image.cgImage else { return nil }
        guard let corlorSpace = cgImg.colorSpace else { return nil }
        
        let bsize:CGFloat = CGFloat(bordersize)
        // Build a context that's the same dimensions as the new size
        let context:CGContext? = CGContext.init(data: nil,
                                                width: Int(image.size.width),
                                                height: Int(image.size.height),
                                                bitsPerComponent: cgImg.bitsPerComponent,
                                                bytesPerRow: 0,
                                                space: corlorSpace,
                                                bitmapInfo: cgImg.bitmapInfo.rawValue)
        // Create a clipping path with rounded corners
        context?.beginPath()
        let rect = CGRect.init(x: bsize, y: bsize, width: image.size.width - bsize * 2, height: image.size.height - bsize * 2)
        
        self.yh_addRoundedRectToPath(rect, context: context, inOvalWidth: CGFloat(cornerSize), inOvalHeight: CGFloat(cornerSize))
        context?.closePath()
        context?.clip()
        
        // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
        context?.draw(cgImg, in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // Create a CGImage from the context
        if let clippedImg = context?.makeImage() {
            return UIImage.init(cgImage: clippedImg)
        }
        
        return nil
    }
    
    // Adds a rectangular path to the given context and rounds its corners by the given extents
    fileprivate func yh_addRoundedRectToPath(_ rect:CGRect, context ctx:CGContext?, inOvalWidth ovalWidth:CGFloat, inOvalHeight ovalHeight:CGFloat) {
        
        if ovalWidth == 0 || ovalHeight == 0 {
            ctx?.addRect(rect)
            return
        }
        ctx?.saveGState()
        ctx?.translateBy(x: rect.minX, y: rect.minY)
        ctx?.scaleBy(x: ovalWidth, y: ovalHeight)
        
        let fw = rect.width / ovalWidth
        let fh = rect.height / ovalHeight
        
        ctx?.move(to: CGPoint.init(x: fw, y: fh/2))
        ctx?.addArc(tangent1End: CGPoint.init(x: fw, y: fh), tangent2End: CGPoint.init(x: fw/2, y: fh/2), radius: 1)
        ctx?.addArc(tangent1End: CGPoint.init(x: 0, y: fh), tangent2End: CGPoint.init(x: 0, y: fh/2), radius: 1)
        ctx?.addArc(tangent1End: CGPoint.init(x: 0, y: 0), tangent2End: CGPoint.init(x: fw/2, y: 0), radius: 1)
        ctx?.addArc(tangent1End: CGPoint.init(x: fw, y: 0), tangent2End: CGPoint.init(x: fw, y: fh/2), radius: 1)

        ctx?.closePath()
        ctx?.restoreGState()
        
    }
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
    fileprivate func yh_transformForOrientation(_ newSize:CGSize) -> CGAffineTransform {
        var transfrom = CGAffineTransform.identity
        let orientation = self.imageOrientation
        if orientation == UIImage.Orientation.down || orientation == UIImage.Orientation.downMirrored
        {
            transfrom = transfrom.translatedBy(x: newSize.width, y: newSize.height)
            transfrom = transfrom.rotated(by: CGFloat.pi)
        }
        else if orientation == UIImage.Orientation.left || orientation == UIImage.Orientation.leftMirrored
        {
            transfrom = transfrom.translatedBy(x: newSize.width, y: 0)
            transfrom = transfrom.rotated(by: CGFloat.pi * 0.5)
        }
        else if orientation == UIImage.Orientation.right || orientation == UIImage.Orientation.rightMirrored
        {
            transfrom = transfrom.translatedBy(x: 0, y: newSize.height)
            transfrom = transfrom.rotated(by: -CGFloat.pi * 0.5)
        }
        
        if orientation == UIImage.Orientation.upMirrored || orientation == UIImage.Orientation.downMirrored
        {
            transfrom = transfrom.translatedBy(x: newSize.width, y: 0)
            transfrom = transfrom.scaledBy(x: -1, y: 1)
        } else if orientation == UIImage.Orientation.leftMirrored || orientation == UIImage.Orientation.rightMirrored
        {
            transfrom = transfrom.translatedBy(x: newSize.height, y: 0)
            transfrom = transfrom.scaledBy(x: -1, y: 1)
        }
        
        return transfrom
    }
}
