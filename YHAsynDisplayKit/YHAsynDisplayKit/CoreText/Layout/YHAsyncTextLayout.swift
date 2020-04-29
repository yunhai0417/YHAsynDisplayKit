//
//  YHAsyncTextLayout.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/4.
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

public struct YHAsyncTextLayoutMaxSize {
    public static let imumWidth:CGFloat = 2000
    public static let imumHeight:CGFloat = 10000000
}

struct YHAsyncTextLayoutFlags {
    var needsLayout:Bool = true
}

public protocol YHAsyncTextLayoutDelegate: NSObjectProtocol {
    /**
     * 当发生截断时，获取截断行的高度
     *
     * @param textLayout 排版模型
     * @param lineRef CTLineRef类型，截断行
     * @param index 截断行的行索引号
     *
     */
    func textLayout(_ textLayout:YHAsyncTextLayout?, truncatedLine:CTLine?, atIndex:UInt) -> CGFloat
}

/*
 YHAsyncTextLayout 是对CoreText排版的封装、入口类
 */
public class YHAsyncTextLayout: NSObject {
    // 待排版的AttributedString
    fileprivate var _attributedString:NSAttributedString?
    public var attributedString:NSAttributedString? {
        set {
            if _attributedString != newValue {
                YHSynchoronized(token: self) {
                    _attributedString = newValue
                }
                self.setNeedsLayout()
            }
        }
        get {
            return _attributedString
        }
    }
    // 可排版区域的size
    fileprivate var _size:CGSize = CGSize.zero
    public var size:CGSize {
        set {
            if !_size.equalTo(newValue) {
                _size = newValue
                _flags.needsLayout = true
            }
        }
        get {
            return _size
        }
    }
    // 最大排版行数，默认为0即不限制排版行数
    fileprivate var _maximumNumberOfLines:UInt = 0
    public var maximumNumberOfLines:UInt {
        set {
            if _maximumNumberOfLines != newValue {
                _maximumNumberOfLines = newValue
                self.setNeedsLayout()
            }
        }
        get {
            return _maximumNumberOfLines
        }
    }
    
    // 是否自动获取 baselineFontMetrics，如果为 YES，将第一行的 fontMetrics 作为 baselineFontMetrics
    public var retriveFontMetricsAutomatically:Bool = false
    // 待排版的AttributedString的基线FontMetrics，当retriveFontMetricsAutomatically=YES时，该值框架内部会自动获取
    fileprivate var _baselineFontMetrics:YHAsyncFontMetrics?
    var baselineFontMetrics:YHAsyncFontMetrics? {
        set {
            if YHAsyncFontMetricsEqual(_baselineFontMetrics, inMetricsRight: newValue) {
                _baselineFontMetrics = newValue
                self.setNeedsLayout()
            }
        }
        get {
            return _baselineFontMetrics
        }
    }
    // 布局受高度限制，如自动截断超过高度的部分，默认为 YES
    var heightSensitiveLayout:Bool = true
    // 如果发生截断，由truncationString指定截断显示内容，默认"..."
    var truncationString:NSAttributedString?
    // 排版模型的代理
    public weak var delegate:YHAsyncTextLayoutDelegate?
    
    private var _flags:YHAsyncTextLayoutFlags = YHAsyncTextLayoutFlags()
    
    fileprivate var _layoutFrame:YHAsyncTextLayoutFrame?
    var layoutFrame:YHAsyncTextLayoutFrame? {
        get {
            if _layoutFrame == nil || _flags.needsLayout {
                YHSynchoronized(token: self) {
                    _layoutFrame = self.createLayoutFrame()
                }
                _flags.needsLayout = false
            }
            
            return _layoutFrame
        }
    }
    
    // 标记当前排版结果需要更新
    func setNeedsLayout() {
        self._flags.needsLayout = true
    }
    
    // 标记当前排版结果是否为最新的
    func layoutUpToDate() -> Bool {
        return !_flags.needsLayout || _layoutFrame == nil
    }
    
    
    override init() {
        super.init()
        self._flags.needsLayout = true
        self.heightSensitiveLayout = true
        self._baselineFontMetrics = YHAsyncFontMetricsNull
    }
    
    fileprivate func createLayoutFrame() -> YHAsyncTextLayoutFrame? {
        guard let attributedString = _attributedString else {
            return nil
        }
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let path = CGMutablePath()
        
        path.addRect(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        //range: 设置多大就显示多少字符。设置为0时，完整显示
        let ctFrame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        
        let layoutFrame = YHAsyncTextLayoutFrame(ctFrame, inTextLayout: self)
        
        return layoutFrame
    }
    
}
