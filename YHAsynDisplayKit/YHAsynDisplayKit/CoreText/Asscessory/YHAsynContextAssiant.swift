//
//  YHAsynContextAssiant.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/3/31.
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

import Foundation
import CoreText
import CoreGraphics

//MARK: Context绘制补充方法
public struct YHAsynContextAssiant {
    /**
     * 为上下文添加圆角区域
     *
     * @param context 上下文
     * @param rect 指定区域
     * @param radius 指定圆角
     *
     */

    static func currentContextAddRoundRect(_ context:CGContext,rect:CGRect,radius:CGFloat) {
        let radius = floor(min(radius, rect.size.width/2, rect.size.height/2))

        context.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + radius))
        context.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - radius))
        context.addArc(center: CGPoint(x: rect.origin.x + radius, y: rect.origin.y + rect.size.height - radius ),
                       radius: radius,
                       startAngle: CGFloat(Double.pi),
                       endAngle: CGFloat(Double.pi)/2,
                       clockwise: true)
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width - radius, y: rect.origin.y + rect.size.height))
        context.addArc(center: CGPoint(x: rect.origin.x + rect.size.width - radius, y: rect.origin.y + rect.size.height - radius ),
                       radius: radius,
                       startAngle: CGFloat(Double.pi) / 2,
                       endAngle: 0,
                       clockwise: true)
        context.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + radius))
        context.addArc(center: CGPoint(x: rect.origin.x + rect.size.width - radius, y: rect.origin.y + radius ),
                       radius: radius,
                       startAngle: 0.0,
                       endAngle: -CGFloat(Double.pi)/2,
                       clockwise: true)
        context.addLine(to: CGPoint(x: rect.origin.x + radius, y: rect.origin.y))
        context.addArc(center: CGPoint(x: rect.origin.x + radius, y: rect.origin.y ),
                       radius: radius,
                       startAngle: -CGFloat(Double.pi)/2,
                       endAngle: CGFloat(Double.pi),
                       clockwise: true)
        
    }
    
    /**
     * 对上下文绘制区域进行圆角裁剪
     *
     * @param context 上下文
     * @param rect 指定区域
     * @param radius 指定圆角
     *
     */
    
    static func currentContextClipRoundRect(_ context:CGContext,rect:CGRect,radius:CGFloat) {
        context.beginPath()
        currentContextAddRoundRect(context, rect: rect, radius: radius)
        context.closePath()
        context.clip()
    }
    
    /**
     * 在指定区域进行圆角绘制
     *
     * @param context 上下文
     * @param rect 指定区域
     * @param radius 期望的圆角值
     *
     */
    static func currentContextFillRoundRect(_ context:CGContext,rect:CGRect,radius:CGFloat) {
        context.beginPath()
        currentContextAddRoundRect(context, rect: rect, radius: radius)
        context.closePath()
        context.fillPath()
    }
    
    /**
     * 梯度绘制
     */
    
    static func currentContextDrawLinearGradientBetweenPoints(_ context:CGContext,a:CGPoint,colora:[CGFloat],b:CGPoint,colorb:[CGFloat]) {
        if colora.count != 4 || colorb.count != 4 {
            print("currentContextDrawLinearGradientBetweenPoints 颜色有问题")
            return
        }
        
        let colorspace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        var components:[CGFloat] = [CGFloat]()
        components.append(contentsOf: colora)
        components.append(contentsOf: colorb)
        
        if let gradient:CGGradient = CGGradient.init(colorSpace: colorspace, colorComponents: components, locations: nil, count: 2) {
            context.drawLinearGradient(gradient, start: a, end: b, options: CGGradientDrawingOptions.init(rawValue: 0))
//          Core Foundation objects are automatically memory managed
//          CGColorSpaceRelease(colorspace)
//          CGGradientRelease(gradient)
        }
        
    }
    
    /**
     * 根据绘制区域、是否不透明创建一个图形上下文
     *
     * @param size 绘制区域的size
     * @param isOpaque 同系统CALayer的同名属性
     *
     * @return CGContextRef 上下文
     */
    static func currentCreateGraphicsContext(_ size:CGSize,isOpaque:Bool) -> CGContext? {
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 8
        let bytesPerRow = 4 * width
        let colorspace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        // 根据位图大小，申请内存空间
        let bitmapData = malloc(bytesPerRow)
        defer {
            free(bitmapData)
        }
        
        if isOpaque {
            let ctx = CGContext.init(data: bitmapData, width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorspace,
                                     bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue)
            
            return ctx
        } else {
            let ctx = CGContext.init(data: bitmapData, width: width,
                                     height: height,
                                     bitsPerComponent: bitsPerComponent,
                                     bytesPerRow: bytesPerRow,
                                     space: colorspace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue)
            
            return ctx
        }
        
        
    }
    
    /**
     * 获取位图上下文的Size
     *
     * @param ctx  上下文
     *
     * @return size
     */
    
    static func achieveBitmapContextPointSize(_ ctx:CGContext) -> CGSize? {
        let width = ctx.width
        let height = ctx.height
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        var transfrom = ctx.ctm
        transfrom = transfrom.inverted()
        bounds = bounds.applying(transfrom)
        return bounds.size
    }
}


