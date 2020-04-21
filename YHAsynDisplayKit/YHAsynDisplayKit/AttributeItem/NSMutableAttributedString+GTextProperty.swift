//
//  NSMutableAttributedString+GTextProperty.swift
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

public enum YHAsyncTextAlignment:NSInteger {
    case left       = 0
    case center     = 1
    case right      = 2
    case justified  = 3
}

public enum YHAsyncTextLigature:NSInteger {
    case properRendering        = 0
    case defaultType            = 1
    case allAvailable           = 2
}

public enum YHAsyncTextUnderlineStyle:NSInteger {
    case none       = 0
    case single     = 1
    case thick      = 2
    case double     = 9
}

struct  YHAsyncTextKeyAttributeName {
    static let StrikethroughStyle     = "YHAsyncTextStrikethroughStyleAttributeName"
    static let StrikethroughColor     = "YHAsyncTextStrikethroughColorAttributeName"
    static let DefaultForegroundColor = "YHAsyncTextDefaultForegroundColorAttributeName"
}

extension NSMutableAttributedString {
    /**
    * 设置字体 range默认 （0，s.length）
    *
    * @param font 字体
    *
    */
    public func yh_setFont(_ font:UIFont) {
        self.yh_setFont(font, withRang: self.yh_stringRange())
    }
    
    /**
    * 设置字体，对AttributedString的指定Range生效
    *
    * @param font 字体
    *
    */
    
    public func yh_setFont(_ font:UIFont?, withRang rang:NSRange) {
        var range = self .yh_effectiveRangeWithRange(rang)
        if font == nil {
            let key = NSAttributedString.Key.init(rawValue: kCTFontAttributeName as String)
            self.removeAttribute(key, range: rang)
        } else {
            let key = NSAttributedString.Key.init(rawValue: kCTFontAttributeName as String)
            self.addAttribute(key, value: font, range: rang)
        }
    }
    
    /**
     * 设置文本字体  range默认 （0，s.length）
     *
     * @param size 指定字号
     * @param weight 指定字重
     * @param boldDisplay 是否加粗
     *
     */
    public func yh_setFontSize(_ size:CGFloat, fontWeight weight:CGFloat, boldDisplay display:Bool) {
        var ctFont:CTFont?
        if #available(iOS 9.0, *) {
            let systemFontName = UIFont.yh_systemFontName()
            if weight != CGFloat.leastNormalMagnitude {
                ctFont = UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: weight))
            } else {
                ctFont = UIFont.yh_newCTFontWithName(systemFontName, size: size)
            }
        } else {
            ctFont = UIFont.yh_newCTFontWithName("HelveticaNeue", size: size)
        }
        
        guard let ctFont1 = ctFont else { return }
        if display {
            let boldCTFont = UIFont.yh_newBoldCTFontForCTFont(ctFont1)
            self.yh_setCTFont(boldCTFont)
        } else {
            self.yh_setCTFont(ctFont1)
        }
    }
    
    /**
    * 设置文本CTFont形式的字体  range默认 （0，s.length）
    *
    * @param ctFont   字体
    *
    */
    public func yh_setCTFont(_ ctFont:CTFont?) {
        self.yh_setCTFont(ctFont, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置文本CTFont形式的字体
    *
    * @param ctFont   字体
    * @param range    range
    *
    */
    public func yh_setCTFont(_ ctFont:CTFont?, inRange range:NSRange) {
        var newRange = self.yh_effectiveRangeWithRange(range)
    
        if ctFont == nil {
            let key = NSAttributedString.Key.init(rawValue: kCTFontAttributeName as String)
            self.removeAttribute(key, range: newRange)
        } else {
            let key = NSAttributedString.Key.init(rawValue: kCTFontAttributeName as String)
            self.addAttribute(key, value: ctFont, range: newRange)
        }
    }
    
    /**
    * 设置文本颜色 range默认 （0，s.length）
    *
    * @param color   字体颜色
    *
    */
    public func yh_setColor(_ color:UIColor?) {
        self.yh_setColor(color, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置文本颜色，仅对指定range生效
    *
    * @param color     字间距
    * @param range     range
    *
    */
    
    public func yh_setColor(_ color:UIColor?, inRange range:NSRange) {
        let key = NSAttributedString.Key.init(rawValue: kCTForegroundColorAttributeName as String)
        let newRange = self.yh_effectiveRangeWithRange(range)
        if color == nil {
            self.removeAttribute(key, range: newRange)
        } else {
            if let cgColor = color?.cgColor {
                self.addAttribute(key, value: cgColor, range: newRange)
                
                if NSEqualRanges(newRange, self.yh_stringRange()) {
                    let key1 = NSAttributedString.Key.init(rawValue: YHAsyncTextKeyAttributeName.DefaultForegroundColor)
                    self.addAttribute(key1, value: cgColor, range: newRange)
                }
            }
        }
    }
    
    /**
    * 设置字间距 range默认 （0，s.length）
    *
    * @param kern     字间距
    *
    */
    public func yh_setKerning(_ kern:CGFloat) {
        self.yh_setKerning(kern, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置字间距，仅对指定range生效
    *
    * @param kern     字间距
    * @param range    指定区间
    *
    */
    public func yh_setKerning(_ kern:CGFloat, inRange range:NSRange) {
        let newRange = self.yh_effectiveRangeWithRange(range)
        let key = NSAttributedString.Key.init(rawValue: kCTKernAttributeName as String)
        let numbC = NSNumber(value: Float(kern))
        self.addAttribute(key, value: numbC, range: newRange)
    }
    
    /**
    * 设置AttributedString的段落风格
    *
    * @param paragraphStyle     段落风格
    * @param fontSize           字号
    *
    */
    public func yh_setTextParagraphStyle(_ paragraphStyle:YHAsyncTextParagraphStyle, fontSize size: CGFloat) {
        let key = kCTLigatureAttributeName as NSAttributedString.Key
        
    }
    
    /**
    * 设置AttributedString的段落对齐方式、换行模式、行高
    *
    * @param alignment          对齐方式
    *
    */
    
    public func yh_setAlignment(_ alignment:YHAsyncTextAlignment) {
        self.yh_setAlignment(alignment, lineBreakMode: NSLineBreakMode.byWordWrapping)
    }
    
    /**
    * 设置AttributedString的段落对齐方式、换行模式、行高
    *
    * @param alignment          对齐方式
    * @param lineBreakMode      换行模式
    *
    */
    
    public func yh_setAlignment(_ alignment:YHAsyncTextAlignment, lineBreakMode mode:NSLineBreakMode) {
        self.yh_setAlignment(alignment, lineBreakMode: mode, lineHeight: 0)
    }
    
    /**
    * 设置AttributedString的段落对齐方式、换行模式、行高
    *
    * @param alignment          对齐方式
    * @param lineBreakMode      换行模式
    * @param lineheight         段落行高
    *
    */
    public func yh_setAlignment(_ alignment:YHAsyncTextAlignment, lineBreakMode mode:NSLineBreakMode, lineHeight height:CGFloat) {
        var nativeLineBreakMode:CTLineBreakMode = CTLineBreakMode.byTruncatingTail
        switch mode {
            case NSLineBreakMode.byWordWrapping:
                nativeLineBreakMode = CTLineBreakMode.byWordWrapping
            case NSLineBreakMode.byCharWrapping:
                nativeLineBreakMode = CTLineBreakMode.byCharWrapping
            case NSLineBreakMode.byClipping:
                nativeLineBreakMode = CTLineBreakMode.byClipping
            case NSLineBreakMode.byTruncatingHead:
                nativeLineBreakMode = CTLineBreakMode.byTruncatingHead
            case NSLineBreakMode.byTruncatingTail:
                nativeLineBreakMode = CTLineBreakMode.byTruncatingTail
            case NSLineBreakMode.byTruncatingMiddle:
                nativeLineBreakMode = CTLineBreakMode.byTruncatingMiddle
        }
        
        var nativeTextAlignment:CTTextAlignment? = CTTextAlignment.left
        switch alignment {
            case YHAsyncTextAlignment.right:
                nativeTextAlignment = CTTextAlignment.right
            case YHAsyncTextAlignment.center:
                nativeTextAlignment = CTTextAlignment.center
            case YHAsyncTextAlignment.justified:
                nativeTextAlignment = CTTextAlignment.justified
            case YHAsyncTextAlignment.left:
                nativeTextAlignment = CTTextAlignment.left
            default:
                nativeTextAlignment = CTTextAlignment.left
        }
        
        var setting:[CTParagraphStyleSetting] = [
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &nativeLineBreakMode),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &nativeTextAlignment)
        ]
        
        let paragraphStyle = CTParagraphStyleCreate(setting, 2)
        
        let key = kCTParagraphStyleAttributeName as NSAttributedString.Key
        
        self.addAttribute(key, value: paragraphStyle, range: self.yh_stringRange())
    }
    
    /**
    * 设置文本连字风格
    *
    */
    public func yh_setTextLigature(_ textLigature:YHAsyncTextLigature) {
        let key = kCTLigatureAttributeName as NSAttributedString.Key
        let number = NSNumber.init(value: textLigature.rawValue)
        
        self.addAttribute(key, value: number, range: self.yh_stringRange())
    }
    
    /**
    * 设置AttributedString的下划线风格、默认颜色0x333333、默认range（0， s.length）
    *
    * @param underlineStyle          下划线风格
    *
    */
    
    public func yh_setUnderlineStyle(_ underlineStyle:YHAsyncTextUnderlineStyle) {
        self.yh_setUnderlineStyle(underlineStyle, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置AttributedString的下划线风格、默认颜色0x333333
    *
    * @param underlineStyle          下划线风格
    * @param range                   下划线添加的range
    *
    */
    public func yh_setUnderlineStyle(_ underlineStyle:YHAsyncTextUnderlineStyle, inRange range:NSRange) {
        
        let underlineColor = UIColor.init(red:((CGFloat)((0x333333 & 0xFF0000) >> 16)) / 255.0,
                                          green: ((CGFloat)((0x333333 & 0xFF00) >> 8)) / 255.0,
                                          blue: ((CGFloat)(0x333333 & 0xFF)) / 255.0,
                                          alpha: 1.0)
        
        self.yh_setUnderlineStyle(underlineStyle, inRange: range, inColor:underlineColor)
        
    }
    
    /**
    * 设置AttributedString的下划线风格、颜色 默认range（0， s.length）
    *
    * @param underlineStyle          下划线风格
    * @param color                   下划线颜色
    *
    */
    public func yh_setUnderlineStyle(_ underlineStyle:YHAsyncTextUnderlineStyle, inColor color:UIColor?) {
        self.yh_setUnderlineStyle(underlineStyle, inRange: self.yh_stringRange(), inColor: color)
    }
    
    /**
    * 设置AttributedString的下划线风格、颜色、指定range
    *
    * @param underlineStyle          下划线风格
    * @param color                   下划线颜色
    * @param range                   下划线添加的range
    *
    */

    public func yh_setUnderlineStyle(_ underlineStyle:YHAsyncTextUnderlineStyle, inRange range:NSRange, inColor color:UIColor?) {
        
        let underLineKey = kCTUnderlineStyleAttributeName as NSAttributedString.Key

        if underlineStyle != YHAsyncTextUnderlineStyle.none {
            let number = NSNumber.init(value: underlineStyle.rawValue)
            self.addAttribute(underLineKey, value: number, range: range)
        }
        
        if let color = color {
            let colorKey = kCTUnderlineColorAttributeName as NSAttributedString.Key
            self.addAttribute(colorKey, value: color, range: range)
        }
        
    }
    
    /**
    * 设置AttributedString指定range的删除线风格 默认0x333333颜色 默认range （0，s.length）
    *
    * @param strikeThroughStyle      删除线风格
    *
    */
    
    public func yh_setStrikeThroughStyle(_ strikeThroughStyle:YHAsyncTextStrikeThroughStyle){
        self.yh_setStrikeThroughStyle(strikeThroughStyle, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置AttributedString指定range的删除线风格 默认0x333333颜色
    *
    * @param strikeThroughStyle      删除线风格
    * @param range                   删除线添加的range
    *
    */
    
    public func yh_setStrikeThroughStyle(_ strikeThroughStyle:YHAsyncTextStrikeThroughStyle, inRange range:NSRange){
        
        let strikeThroughColor = UIColor(red:((CGFloat)((0x999999 & 0xFF0000) >> 16)) / 255.0,
                                     green: ((CGFloat)((0x999999 & 0xFF00) >> 8)) / 255.0,
                                     blue: ((CGFloat)(0x999999 & 0xFF)) / 255.0,
                                     alpha: 1.0)
        
        self.yh_setStrikeThroughStyle(strikeThroughStyle, inColor: strikeThroughColor, inRange: range)

    }
    
    /**
    * 设置AttributedString指定range的删除线风格、颜色
    *
    * @param strikeThroughStyle      删除线风格
    * @param color                   删除线颜色
    *
    */
    public func yh_setStrikeThroughStyle(_ strikeThroughStyle:YHAsyncTextStrikeThroughStyle, inColor color:UIColor){
        self.yh_setStrikeThroughStyle(strikeThroughStyle, inColor: color, inRange: self.yh_stringRange())
    }
    
    /**
    * 设置AttributedString指定range的删除线风格、颜色
    *
    * @param strikeThroughStyle      删除线风格
    * @param color                   删除线颜色
    * @param range                   删除线添加的range
    *
    */
    
    public func yh_setStrikeThroughStyle(_ strikeThroughStyle:YHAsyncTextStrikeThroughStyle, inColor color:UIColor?, inRange range:NSRange){
        let strikey = NSAttributedString.Key.init(YHAsyncTextKeyAttributeName.StrikethroughStyle)
        if strikeThroughStyle != .None {
            let number = NSNumber.init(value: strikeThroughStyle.rawValue)
            self.addAttribute(strikey, value: number, range: range)
        }
        
        if let color = color {
            let colorkey = NSAttributedString.Key.init(YHAsyncTextKeyAttributeName.StrikethroughColor)
            self.addAttribute(colorkey, value: color, range: range)
        }
    }
}

extension NSMutableAttributedString {
    
    func yh_stringRange() -> NSRange {
        return NSRange.init(location: 0, length: self.length)
    }
    
    func yh_effectiveRangeWithRange(_ range:NSRange) -> NSRange {
        let stringLength = self.length
        var newRange = range
        if newRange.location == NSNotFound || newRange.location > stringLength {
            newRange.location = 0
        }
        
        if newRange.location + newRange.length > stringLength {
            newRange.length = stringLength - newRange.location
        }
        
        return newRange
    }
}
