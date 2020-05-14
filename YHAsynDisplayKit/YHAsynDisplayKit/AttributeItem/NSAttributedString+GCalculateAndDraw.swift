//
//  NSAttributedString+GCalculateAndDraw.swift
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
import Foundation
import CoreGraphics

struct YHAsyncTextLayoutSizeKey {
    static let maximumWidth:CGFloat  = 2000;
    static let maximumHeight:CGFloat = 10000000;
}

public typealias YHAsyncTextDrawingFrameBlock = (_ size:CGSize) -> CGRect

//MARK: - 获取文本绘制器

extension NSAttributedString {
    public class func textDrawerForCurrentThread() -> YHAsyncTextDrawer {
        let currentThread = Thread.current
        if let drawer = currentThread.associationDrawer {
            return drawer
        }
        let drawer = YHAsyncTextDrawer.init()
        currentThread.associationDrawer = drawer
        
        return drawer
    }
    
    /**
    * 获取一个文本绘制器
    *
    * @discussion 以线程内共享方式返回一个文本绘制器，同一个线程获取的对象是同一个，不同的线程获取到的不一样
    *
    * @return WMGTextDrawer
    */
    public class func attributedSharedTextDrawer() -> YHAsyncTextDrawer {
        
        return self.textDrawerForCurrentThread()
    }
    
    public func attributedSharedTextDrawer() -> YHAsyncTextDrawer {
        
        return NSAttributedString.attributedSharedTextDrawer()
    }
    
}

//MARK: - NSAttributedString Size
extension NSAttributedString {
    /**
    * 计算AttributedString的size
    *
    * @return size
    */
    public func attributedSize() -> CGSize {
        let size = CGSize(width: YHAsyncTextLayoutSizeKey.maximumWidth,
                          height: YHAsyncTextLayoutSizeKey.maximumHeight)
        return self.yh_sizeConstrainedToSize(size)
    }
    
    /**
    * 计算AttributedString的size
    *
    * @param size              限定size
    *
    * @return size
    */
    public func yh_sizeConstrainedToSize(_ size:CGSize) -> CGSize {
        
        return self.yh_sizeConstrainedToSize(size, numberOfLines: 0)
    }
    
    /**
    * 计算AttributedString的size
    * @param size              限定size
    * @param numberOfLines     限定行数
    *
    * @return size
    */
    public func yh_sizeConstrainedToSize(_ size:CGSize, numberOfLines lines:NSInteger = 0) -> CGSize {
        var derivedLineCount:NSInteger? = 0
        return self.yh_sizeConstrainedToSize(size, numberOfLines: lines, derivedLineCount: &derivedLineCount)
    }
    
    /**
    * 计算AttributedString的size
    *
    * @param size              限定size
    * @param numberOfLines     限定行数
    * @param derivedLineCount  实际占用的行数
    *
    * @return size
    */
    
    public func yh_sizeConstrainedToSize(_ size:CGSize, numberOfLines lines:NSInteger, derivedLineCount count:inout NSInteger?) -> CGSize {
        return self.yh_sizeConstrainedToSize(size, numberOfLines: lines, derivedLineCount: &count, baselineMetrics: YHAsyncFontMetricsNull)
    }
    
    fileprivate func yh_sizeConstrainedToSize(_ size:CGSize, numberOfLines lines:NSInteger, derivedLineCount count:inout NSInteger?, baselineMetrics metrics:YHAsyncFontMetrics) -> CGSize {
        
        var size1 = size
        size1.width = min(YHAsyncTextLayoutSizeKey.maximumWidth, size1.width)
        size1.height = min(YHAsyncTextLayoutSizeKey.maximumHeight, size1.height)
        
        let layout = NSAttributedString.attributedSharedTextDrawer().textLayout
        layout.attributedString = self
        layout.size = size1
        layout.maximumNumberOfLines = UInt(lines)
        layout.baselineFontMetrics = metrics
        
        if let textSize = layout.layoutFrame?.layoutSize {
            layout.maximumNumberOfLines = 0
            if let arrayLines = layout.layoutFrame?.arrayLines {
                count = arrayLines.count
            }
            
            size1.width = max(textSize.width, CGSize.zero.width)
            size1.width = min(textSize.width, size1.width)
            
            size1.height = max(textSize.height, CGSize.zero.width)
            size1.height = min(textSize.height, size1.height)
        }
        return size1
    }
    
    /**
    * 计算AttributedString的size
    *
    * @param width         限定宽度
    * @param numberOfLines 限定行数
    *
    * @return size
    */
    
    public func attributedSizeConstrained(_ inWidth:CGFloat, numberOfLines inlines:NSInteger = 0) -> CGSize {
        
        let size = CGSize.init(width: inWidth,
                               height: YHAsyncTextLayoutSizeKey.maximumHeight)
        
        return self.yh_sizeConstrainedToSize(size, numberOfLines: inlines)
    }
    
    /**
    * 计算AttributedString的高度
    *
    * @param width 限定的宽度
    *
    * @return 高度
    */
    
    public func attributedHeightConstrained(_ inWidth:CGFloat) -> CGFloat {
        let layout = NSAttributedString.attributedSharedTextDrawer().textLayout
        layout.maximumNumberOfLines = 0
        layout.attributedString = self
        layout.size = CGSize(width: inWidth, height: YHAsyncTextLayoutSizeKey.maximumHeight)
        
        if let height = layout.layoutFrame?.layoutSize?.height {
            return height
        }
        return -1
    }
}

//MARK: - Draw in Rect
extension NSAttributedString {
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    *
    * @return 绘制结果占用的size
    */
    public func yh_drawInRect(_ rect:CGRect) -> CGSize? {
        
        return self.yh_drawInRect(rect, context:UIGraphicsGetCurrentContext())
        
    }
    
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param ctx 上下文
    *
    * @return 绘制结果占用的size
    */

    public func yh_drawInRect(_ rect:CGRect, context ctx:CGContext?) -> CGSize? {
        
        return self.yh_drawInRect(rect, numberOflines: 0, context: ctx)
    }
    
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param numberOfLines 限定行数
    * @param ctx 上下文
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, numberOflines lines:NSInteger = 0, context ctx:CGContext?) -> CGSize? {
        
        return self.yh_drawInRect(rect, numberOflines: lines, baselineMetrics: YHAsyncFontMetricsNull, context: ctx)
    }
    
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param numberOfLines 限定行数
    * @param metrics fontMetrics
    * @param ctx 上下文
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, numberOflines lines:NSInteger, baselineMetrics metrics:YHAsyncFontMetrics , context ctx:CGContext?) -> CGSize? {
        guard let context = ctx else { return nil }
        let drawer:YHAsyncTextDrawer = NSAttributedString.attributedSharedTextDrawer()
        drawer.textLayout.maximumNumberOfLines = UInt(lines)
        drawer.textLayout.baselineFontMetrics = metrics
        drawer.textLayout.attributedString = self
        drawer.frame = rect
        
        drawer.drawInContext(context)
        
        let layoutSize = drawer.textLayout.layoutFrame?.layoutSize
        return layoutSize
    }
    
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param numberOfLines 限定行数
    * @param metrics fontMetrics
    * @param ctx 上下文
    * @param textDrawer 文本绘制器
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, numberOflines lines:NSInteger, baselineMetrics metrics:YHAsyncFontMetrics, context ctx:CGContext?, textDrawer drawer:YHAsyncTextDrawer?) -> CGSize? {
        guard let context = ctx else { return nil }
        var textDrawer:YHAsyncTextDrawer?
        if let drawer = drawer {
            textDrawer = drawer
        } else {
            textDrawer = NSAttributedString.attributedSharedTextDrawer()
        }
        textDrawer?.textLayout.maximumNumberOfLines = UInt(lines)
        textDrawer?.textLayout.baselineFontMetrics = metrics
        
        textDrawer?.textLayout.attributedString = self
        
        textDrawer?.frame = rect
        
        textDrawer?.drawInContext(context)
        
        let layoutSize = textDrawer?.textLayout.layoutFrame?.layoutSize
        
        return layoutSize
    }
}

//Mark -- Size Based Drawing
extension NSAttributedString {
    /**
    * 将AttributedString以限定宽度绘制到某一个区域
    *
    * @param width 限定宽度
    * @param frameBlock frameBlock
    *
    */
    func yh_drawWithWidth(_ width:CGFloat, frameBlock block:YHAsyncTextDrawingFrameBlock?) {
        self.yh_drawWithWidth(width, numberOfLines: 0, context: UIGraphicsGetCurrentContext(), frameBlock: block)
    }
    
    /**
    * 将AttributedString以限定条件绘制到某一个区域
    *
    * @param width 限定宽度
    * @param numberOfLines 限定行数
    * @param ctx 上下文
    * @param frameBlock frameBlock
    *
    */
    func yh_drawWithWidth(_ width:CGFloat, numberOfLines lines:NSInteger, context ctx:CGContext?, frameBlock block:YHAsyncTextDrawingFrameBlock?) {
        guard let context = ctx else { return }
        guard let frameBlock = block else { return }
        
        var drawer:YHAsyncTextDrawer = NSAttributedString.attributedSharedTextDrawer()
        
        drawer.textLayout.maximumNumberOfLines = UInt(lines)
        drawer.textLayout.heightSensitiveLayout = false
        
        drawer.textLayout.attributedString = self
        
        drawer.frame = CGRect(x: 0, y: 0, width: width, height: 1)
        
        if let size = drawer.textLayout.layoutFrame?.layoutSize {
            let frame = frameBlock(size)
            drawer.frame = frame
        }
        drawer.drawInContext(context)
        
        drawer.textLayout.heightSensitiveLayout = true
        drawer.textLayout.maximumNumberOfLines = 0
        
        
    }
    
    /**
    * 将AttributedString以限定条件进行布局
    *
    * @param width 限定宽度
    * @param lines 限定行数
    *
    * @return WMGTextLayout
    */
    public func layoutToWidth(_ width:CGFloat, maxNumberOfLines lines:NSInteger) -> YHAsyncTextLayout {
        return self.layoutToWidth(width, maxNumberOfLines: lines, layoutSize: CGSize.zero)
    }
    
    /**
    * 将AttributedString以限定条件进行布局
    *
    * @param width         限定宽度
    * @param lines         限定行数
    * @param layoutSize    布局结果的排版size
    *
    * @return WMGTextLayout
    */
    public func layoutToWidth(_ width:CGFloat, maxNumberOfLines lines:NSInteger, layoutSize size:CGSize) -> YHAsyncTextLayout {
        let layout = NSAttributedString.attributedSharedTextDrawer().textLayout
        layout.maximumNumberOfLines = UInt(lines)
        layout.attributedString = self
        
        if !size.equalTo(CGSize.zero) {
            layout.size = size
        } else {
            layout.size = CGSize.init(width: width, height: YHAsyncTextLayoutSizeKey.maximumHeight)
        }
        
//        layout.layoutFrame?.layoutSize
        
        return layout
    }
}

var YHAsyncStringLayoutSizeCache = [String:CGSize]()
//#pragma mark - Size
extension NSString {
    /**
    * 获取NSString的cachesize
    *
    * @param font              限定字体
    *
    * @return size
    *
    * @discussion 根据NSString内容和当前的UIFont联合作为key做缓存，如果没有缓存调用yh_sizeWithFont计算返回
    */
    public func yh_cacheSizeWithFont(_ font:UIFont) -> CGSize {
        let cacheKey:String = "\(self.hash)-\(font.hash)"
        
        if let sizeValue:CGSize = YHAsyncStringLayoutSizeCache[cacheKey] {
            return sizeValue
        }
        
        let size = self.yh_sizeWithFont(font)
        YHAsyncStringLayoutSizeCache[cacheKey] = size
        return size
    }
    
    /**
    * 计算NSString的size
    *
    * @param font              限定字体
    *
    * @return size
    */
    
    public func yh_sizeWithFont(_ font:UIFont) -> CGSize {
        var str:NSMutableAttributedString = NSMutableAttributedString.init(string: self as String)
        str.yh_setFont(font)
        return str.attributedSize()
    }
    
    /**
    * 计算NSString的size
    *
    * @param font              限定字体
    * @param size              限定size
    *
    * @return size
    */
    public func yh_sizeWithFont(_ font:UIFont, constrainedToSize size:CGSize) -> CGSize? {
        return self.yh_sizeWithFont(font, constrainedToSize: size, lineBreakMode: NSLineBreakMode.byWordWrapping)
    }
    
    /**
    * 计算NSString的size
    *
    * @param font              限定字体
    * @param size              限定size
    * @param lineBreakMode     换行模式
    *
    * @return size
    */
    public func yh_sizeWithFont(_ font:UIFont, constrainedToSize size:CGSize,lineBreakMode mode:NSLineBreakMode) -> CGSize? {
        return self.yh_sizeWithFont(font, constrainedToSize: size, lineBreakMode: mode, numberOfLines: 0)
    }
    
    /**
    * 计算NSString的size
    *
    * @param font              限定字体
    * @param size              限定size
    * @param lineBreakMode     换行模式
    * @param numberOfLines     限定行数
    *
    * @return size
    */
    public func yh_sizeWithFont(_ font:UIFont, constrainedToSize size:CGSize,lineBreakMode mode:NSLineBreakMode, numberOfLines lines:NSInteger) -> CGSize {
        var str:NSMutableAttributedString = NSMutableAttributedString.init(string: self as String)
        str.yh_setFont(font)
        str.yh_setAlignment(YHAsyncTextAlignment.left, lineBreakMode: mode)
        var count:NSInteger? = 0
        return str.yh_sizeConstrainedToSize(size, numberOfLines: lines, derivedLineCount: &count , baselineMetrics: YHAsyncFontMetricsCreateMake(font))
    }
    
}

//#pragma mark - Draw at Points
extension NSString {
    public func yh_drawAtPoint(_ point:CGPoint, withFont font:UIFont) -> CGSize? {
        return self.yh_drawAtPoint(point, withFont: font, forWidth:YHAsyncTextLayoutMaxSize.imumWidth, lineBreakMode: NSLineBreakMode.byWordWrapping)
    }
    
    func yh_drawAtPoint(_ point:CGPoint, withFont font:UIFont,forWidth width:CGFloat, lineBreakMode mode:NSLineBreakMode) -> CGSize? {
        
        let textRect = CGRect.init(x: point.x, y: point.y, width: width, height: font.lineHeight)
        return self.yh_drawInRect(textRect, withFont: font, lineBreakMode: mode)
    }
}

//#pragma mark - Draw in Rect
extension NSString {
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    *
    * @return 绘制结果占用的size
    */
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont) -> CGSize? {
        
        return self.yh_drawInRect(rect, withFont: font, lineBreakMode: NSLineBreakMode.byWordWrapping)
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    * @param lineBreakMode 换行模式
    *
    * @return 绘制结果占用的size
    */
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode) -> CGSize? {
        
        return self.yh_drawInRect(rect, withFont: font, lineBreakMode: mode, withAlignment: NSTextAlignment.left)
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    * @param lineBreakMode 换行模式
    * @param alignment 对齐方式
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode, withAlignment alignment:NSTextAlignment) -> CGSize? {
        
        return self.yh_drawInRect(rect, withFont: font, lineBreakMode: mode, withAlignment: alignment, context: UIGraphicsGetCurrentContext())
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    * @param lineBreakMode 换行模式
    * @param alignment 对齐方式
    * @param context 上下文
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode, withAlignment alignment:NSTextAlignment ,context ctx:CGContext?) -> CGSize? {
        
        return self.yh_drawInRect(rect, withFont: font, lineBreakMode: mode, withAlignment: alignment, numberOfLines: 0, context: ctx)
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    * @param lineBreakMode 换行模式
    * @param alignment 对齐方式
    * @param numberOfLines 限定行数
    * @param context 上下文
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode, withAlignment alignment:NSTextAlignment, numberOfLines lines:NSInteger, context ctx:CGContext?) -> CGSize? {
        var str = NSMutableAttributedString.init(string: self as String)
        let colorKey = kCTForegroundColorFromContextAttributeName as NSAttributedString.Key
        let styleKey = kCTParagraphStyleAttributeName as NSAttributedString.Key
        
        str.addAttribute(colorKey, value: NSNumber.init(value: true), range: NSRange.init(location: 0, length: self.length))
        
        let styleValue = self.paragraphStyleWithLineBreakMode(mode, textAlignment: alignment, lineHeight: rect.size.height)
        
        str.addAttribute(styleKey, value: styleValue, range: NSRange.init(location: 0, length: self.length))

        str.yh_setFont(font)
        
        return str.yh_drawInRect(rect, numberOflines: lines, baselineMetrics: YHAsyncFontMetricsCreateMake(font), context: ctx)
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param rect 限定区域
    * @param font 字体
    * @param lineBreakMode 换行模式
    * @param alignment 对齐方式
    * @param numberOfLines 限定行数
    * @param context 上下文
    * @param textDrawer 文本绘制器
    *
    * @return 绘制结果占用的size
    */
    
    public func yh_drawInRect(_ rect:CGRect, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode, withAlignment alignment:NSTextAlignment, numberOfLines lines:NSInteger, context ctx:CGContext, textDrawer drawer:YHAsyncTextDrawer) -> CGSize? {
        
        var str = NSMutableAttributedString.init(string: self as String)
        let colorKey = kCTForegroundColorFromContextAttributeName as NSAttributedString.Key
        let styleKey = kCTParagraphStyleAttributeName as NSAttributedString.Key
        
        str.addAttribute(colorKey, value: NSNumber.init(value: true), range: NSRange.init(location: 0, length: self.length))
        
        let styleValue = self.paragraphStyleWithLineBreakMode(mode, textAlignment: alignment, lineHeight: rect.size.height)
        
        str.addAttribute(styleKey, value: styleValue, range: NSRange.init(location: 0, length: self.length))

        str.yh_setFont(font)
        
        return str.yh_drawInRect(rect, numberOflines: lines, baselineMetrics: YHAsyncFontMetricsCreateMake(font), context: ctx, textDrawer: drawer)
    }
    
}

//#pragma mark - Size Based Drawing
extension NSString {
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param width 限定宽度
    * @param font 字体
    * @param frameBlock frameBlock
    *
    */
    public func yh_drawWithWidth(_ width:CGFloat, withFont font:UIFont, frameBlock block:YHAsyncTextDrawingFrameBlock?) {
        self.yh_drawWithWidth(width, withFont: font, lineBreakMode: NSLineBreakMode.byWordWrapping, withAlignment: NSTextAlignment.left, numberOfLines: 0, context: UIGraphicsGetCurrentContext(), frameBlock: block)
    }
    
    /**
    * 将String以限定条件绘制到某一个区域
    *
    * @param width         限定宽度
    * @param font          字体
    * @param lineBreakMode 换行模式
    * @param alignment     对齐方式
    * @param numberOfLines 限定行数
    * @param context       上下文
    * @param frameBlock frameBlock
    *
    */
    
    public func yh_drawWithWidth(_ width:CGFloat, withFont font:UIFont, lineBreakMode mode:NSLineBreakMode, withAlignment alignment:NSTextAlignment, numberOfLines lines:NSInteger, context ctx:CGContext?, frameBlock block:YHAsyncTextDrawingFrameBlock?) {
        var str = NSMutableAttributedString.init(string: self as String)
        let colorKey = kCTForegroundColorFromContextAttributeName as NSAttributedString.Key
        let styleKey = kCTParagraphStyleAttributeName as NSAttributedString.Key
        
        str.addAttribute(colorKey, value: NSNumber.init(value: true), range: NSRange.init(location: 0, length: self.length))
        
        let styleValue = self.paragraphStyleWithLineBreakMode(mode, textAlignment: alignment, lineHeight: font.lineHeight)
        
        str.addAttribute(styleKey, value: styleValue, range: NSRange.init(location: 0, length: self.length))

        str.yh_setFont(font)
        
        str.yh_drawWithWidth(width, numberOfLines: lines, context: ctx, frameBlock: block)
    }
}

extension NSString {
    func paragraphStyleWithLineBreakMode(_ lineBreakMode:NSLineBreakMode, textAlignment alignment:NSTextAlignment, lineHeight height:CGFloat) -> CTParagraphStyle? {
        var maxLineHeight:CGFloat = height
        var vlineBreakMode = lineBreakMode
        var valignment = alignment
        
        let setting:[CTParagraphStyleSetting] = [
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &vlineBreakMode),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &valignment),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &maxLineHeight)
        ]
        
        return CTParagraphStyleCreate(setting, 3)
    }
}
