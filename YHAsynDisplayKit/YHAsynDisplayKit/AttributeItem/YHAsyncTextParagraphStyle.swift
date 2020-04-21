//
//  YHAsyncTextParagraphStyle.swift
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

struct YHAsyncTextParagraphStyleDelegateHas {
    var didUpdateAttribute:Bool = true
}

@objc protocol YHAsyncTextParagraphStyleDelegate: NSObjectProtocol {
    @objc func paragraphStyleDidUpdated(_ style:YHAsyncTextParagraphStyle)
}

public class YHAsyncTextParagraphStyle: NSObject {
    
    fileprivate var isNeedChaneSpace:Bool = true
    // 段落风格代理
    fileprivate weak var _delegate:YHAsyncTextParagraphStyleDelegate?
    weak var delegate:YHAsyncTextParagraphStyleDelegate? {
        set {
            if let newValue = newValue {
                if newValue.isEqual(_delegate) {
                    _delegate = newValue
                    delegateHas.didUpdateAttribute = newValue.responds(to: #selector(YHAsyncTextParagraphStyleDelegate.paragraphStyleDidUpdated(_:)))
                }
                
            } else {
                _delegate = nil
                delegateHas.didUpdateAttribute = false
            }
        }
        get {
            return _delegate
        }
    }
    fileprivate var delegateHas = YHAsyncTextParagraphStyleDelegateHas()

    // 获取默认段落风格，每次调用都会创建一个实例返回。
    fileprivate var _allowsDynamicLineSpacing:Bool = false
    public var allowsDynamicLineSpacing:Bool {
        set {
            if _allowsDynamicLineSpacing != newValue {
                _allowsDynamicLineSpacing = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _allowsDynamicLineSpacing
        }
    }
    
    // 行间距，默认值5
    fileprivate var _lineSpacing:CGFloat = 5
    public var lineSpacing:CGFloat {
        set {
            if _lineSpacing != newValue {
                _lineSpacing = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _lineSpacing
        }
    }
    
    // 最大行高
    fileprivate var _maximumLineHeight:CGFloat = 0
    public var maximumLineHeight:CGFloat {
        set {
            if _maximumLineHeight != newValue {
                _maximumLineHeight = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _maximumLineHeight
        }
    }
    
    // 换行模式，默认NSLineBreakByWordWrapping
    fileprivate var _lineBreakMode:NSLineBreakMode = NSLineBreakMode.byWordWrapping
    public var lineBreakMode:NSLineBreakMode {
        set {
            if _lineBreakMode != newValue {
                _lineBreakMode = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _lineBreakMode
        }
    }
    
    // 对齐风格，默认NSTextAlignmentLeft
    fileprivate var _alignment:NSTextAlignment = NSTextAlignment.left
    public var alignment:NSTextAlignment{
        set {
            if _alignment != newValue {
                _alignment = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _alignment
        }
    }
    
    // 段落首行头部缩进
    fileprivate var _firstLineHeadIndent:CGFloat = 0
    public var firstLineHeadIndent:CGFloat {
        set {
            if _firstLineHeadIndent != newValue {
                _firstLineHeadIndent = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _firstLineHeadIndent
        }
    }
    
    // 段落前间距
    fileprivate var _paragraphSpacingBefore:CGFloat = 0
    public var paragraphSpacingBefore:CGFloat {
        set {
            if _paragraphSpacingBefore != newValue {
                _paragraphSpacingBefore = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _paragraphSpacingBefore
        }
    }
    
    // 段落后间距
    fileprivate var _paragraphSpacingAfter:CGFloat = 0
    public var paragraphSpacingAfter:CGFloat {
        set {
            if _paragraphSpacingAfter != newValue {
                _paragraphSpacingAfter = newValue
                self.propertyUpdated()
            }
        }
        get {
            return _paragraphSpacingAfter
        }
    }
    
   
    
    //MARK: - func
    
    /**
    * 获取默认段落风格，每次调用都会创建一个实例返回。
    *
    * @return WMGTextParagraphStyle
    */
    public class func defaultParagraphStyle() -> YHAsyncTextParagraphStyle {
        var paragraphStyle = YHAsyncTextParagraphStyle.init()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.allowsDynamicLineSpacing = true
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.left
        return paragraphStyle
        
    }
    
    override public init() {
        super.init()
        self.isNeedChaneSpace = !UIDevice.isFullScreenSerise
    }
    
    
    
    /**
    * 根据指定字号获取NS类型的段落对象
    * @param fontSize 字号大小
    *
    * @return NSParagraphStyle
    */
    
    public func nsParagraphStyleWithFontSize(_ fontSize:NSInteger) -> NSParagraphStyle? {
        var minLineHeight:CGFloat = CGFloat(fontSize) + self.lineSpacing
        var maxLineHeight:CGFloat = self.maximumLineHeight
        
        if maxLineHeight == 0 {
            maxLineHeight = self.allowsDynamicLineSpacing ? minLineHeight : minLineHeight
        }
        
        var paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.alignment
        paragraphStyle.baseWritingDirection = NSWritingDirection.leftToRight
        paragraphStyle.maximumLineHeight = maxLineHeight
        paragraphStyle.minimumLineHeight = minLineHeight
        if isNeedChaneSpace {
            paragraphStyle.lineSpacing = 1
        } else {
            paragraphStyle.lineSpacing = 2
        }
        paragraphStyle.firstLineHeadIndent = self.firstLineHeadIndent
        paragraphStyle.paragraphSpacingBefore = self.paragraphSpacingBefore
        paragraphStyle.paragraphSpacing = self.paragraphSpacingAfter
        
        return paragraphStyle
    }
    
    /**
    * 根据指定字号获取CT类型的段落对象
    * @param fontSize 字号大小
    *
    * @return CTParagraphStyleRef
    */
    
    public func ctParagraphStyleWithFontSize(_ fontSize:NSInteger) -> CTParagraphStyle? {
        var minLineHeight:CGFloat = CGFloat(fontSize) + self.lineSpacing
        var maxLineHeight:CGFloat = self.maximumLineHeight
        
        if maxLineHeight == 0 {
            maxLineHeight = self.allowsDynamicLineSpacing ? minLineHeight : minLineHeight
        }
        
        var lineBreakMode:CTLineBreakMode = CTLineBreakMode(rawValue: UInt8(self.alignment.rawValue)) ?? CTLineBreakMode.byWordWrapping
        var textAlignment:CTTextAlignment = CTTextAlignment(self.alignment)
        var writingDirection:CTWritingDirection = CTWritingDirection.leftToRight
        
        var space:CGFloat = self.isNeedChaneSpace ? 1.0 : 2.0
        
        var minLineSpaceing = space
        var maxLineSpaceing = space
        
        let setting:[CTParagraphStyleSetting] = [
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &lineBreakMode),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &textAlignment),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.baseWritingDirection, valueSize: MemoryLayout<CTWritingDirection>.size, value: &writingDirection),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.minimumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &minLineHeight),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &maxLineHeight),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &minLineSpaceing),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &maxLineSpaceing),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.paragraphSpacingBefore, valueSize: MemoryLayout<CGFloat>.size, value: &self.paragraphSpacingBefore),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &self.paragraphSpacingAfter),
            CTParagraphStyleSetting.init(spec: CTParagraphStyleSpecifier.headIndent, valueSize: MemoryLayout<CGFloat>.size, value: &self.firstLineHeadIndent)
        ]
        
        let ptype = CTParagraphStyleCreate(setting, 10)
        
        return ptype
    }
}

extension YHAsyncTextParagraphStyle {
    fileprivate func propertyUpdated() {
        self.delegate?.paragraphStyleDidUpdated(self)
    }
}
