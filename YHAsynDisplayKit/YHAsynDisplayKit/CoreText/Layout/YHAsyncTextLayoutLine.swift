//
//  YHAsyncTextLayoutLine.swift
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

import Foundation
import CoreText
import CoreGraphics

typealias runsUsingBlock = (_ run:CTRun, _ attribute:NSDictionary, _ characterRange:NSRange) -> Void

public class YHAsyncTextLayoutLine: NSObject {
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     *  根据一个截断前的原始CTLineRef、人为截断的CTLineRef进行初始化
     *
     *  @param lineRef 截断前CoreText的行
     *  @param truncatedLineRef 截断后的CoreText的行
     *  @param baselineOrigin 基线原点
     *  @param textLayout 行所在的TextLayout
     *
     *  @return YHAsyncTextLayoutLine
     */
    init(_ lineRef:CTLine?, truncatedLineRef:CTLine?, baselineOrigin:CGPoint, textLayout:YHAsyncTextLayout) {
        super.init()
        if let lineRef = lineRef {
            self.truncated = truncatedLineRef != nil
            var templineRef:CTLine = self.truncated ? truncatedLineRef! : lineRef
            self.lineRef = templineRef
            
            var lineAscent = CGFloat()
            var lineDescent = CGFloat()
            var lineLeading = CGFloat()
            self.lineWidth = CGFloat(CTLineGetTypographicBounds(templineRef, &lineAscent, &lineDescent, &lineLeading))
            
            let range:CFRange = CTLineGetStringRange(templineRef)
            self.originStringRange = NSRange.init(location: range.location, length: range.length)
            
            if  let truncatedline = self.lineRef  {
                let truncatedRange:CFRange = CTLineGetStringRange(truncatedline)
                self.truncatedStringRange = NSRange.init(location: truncatedRange.location, length: truncatedRange.length)
                self.originStringRange?.length = truncatedRange.length
                
            }
            
            self.originalFontMetrics = YHAsyncFontMetricsCreateMake(abs(lineAscent),
                                                              indescent: abs(lineDescent),
                                                              inleading: abs(lineLeading))
            
            self.fontMetrics = YHAsyncFontMetricsCreateMake(abs(lineAscent),
                                                      indescent: abs(lineDescent),
                                                      inleading: abs(lineLeading))
            
            if let leading = textLayout.baselineFontMetrics?.leading {
                if leading != CGFloat(NSNotFound) {
                    if let fontLeading = self.fontMetrics?.leading {
                        self.fontMetrics?.leading = min(fontLeading, 3 * leading)
                    }
                }
            }
            
            self.originalBaselineOrigin = baselineOrigin
            // 基线调整
            var baselineOriginY = baselineOrigin.y
            if let baseFontDescent = textLayout.baselineFontMetrics?.descent, let fontDescent = self.fontMetrics?.descent {
                if baseFontDescent != CGFloat(NSNotFound) {
                    baselineOriginY -= fontDescent - baseFontDescent
                }
            }
            
            if let leading = textLayout.baselineFontMetrics?.leading, let fontLeading = self.fontMetrics?.leading {
                if leading != CGFloat(NSNotFound) {
                    baselineOriginY -= fontLeading - leading
                }
            }
            
            if let fontMetrics = self.fontMetrics {
                let lineHeight = fontMetrics.ascent + fontMetrics.descent + fontMetrics.leading
                var ceilResult = CGFloat(ceilf(Float(lineHeight))) - lineHeight
                ceilResult += 1
                
                baselineOriginY -= ceilResult
            }
            
            self.baselineOrigin = CGPoint.init(x: baselineOrigin.x, y: floor(baselineOriginY))
            // CoreText Coordinate Convert to UI Coordinate
            self.originalBaselineOrigin = textLayout.yhAsyncUIPointFromCTPoint(self.originalBaselineOrigin)
            self.baselineOrigin = textLayout.yhAsyncUIPointFromCTPoint(self.baselineOrigin)
            
            if let ascent = textLayout.baselineFontMetrics?.ascent {
                if ascent == CGFloat(NSNotFound) && textLayout.retriveFontMetricsAutomatically {
                    textLayout.baselineFontMetrics = self.fontMetrics
                }
            }
            // 删除线
            guard let originStringRange = self.originStringRange else { return }
            guard let baselineOrigin = self.baselineOrigin else { return }
            var array = [CGRect]()
            let attributeKey = NSAttributedString.Key(rawValue: YHAsyncTextKeyAttributeName.StrikethroughStyle)

            textLayout.attributedString?.enumerateAttribute(attributeKey, in: originStringRange, options: [], using: { (value, range, stop) in
                if let value = value as? NSInteger {
                    let style:YHAsyncTextStrikeThroughStyle =  YHAsyncTextStrikeThroughStyle(rawValue: value) ?? .None
                    let start = self.offsetXForCharacterAtIndex(range.location)
                    let end = self.offsetXForCharacterAtIndex(NSMaxRange(range))
                    array.append(CGRect.init(x: start,
                                             y: baselineOrigin.y - 3,
                                             width: end - start ,
                                             height: style == YHAsyncTextStrikeThroughStyle.Single ? 1 : 2 ))
                }
            })
            
            self.strikeThroughFrames = array
        }  else {
            
        }
    }
    
    
    private var _lineWidth:CGFloat = 0.0
    var lineWidth:CGFloat {
        set {
            if _lineWidth != newValue {
                _lineWidth = newValue
            }
        }
        get {
            return _lineWidth
        }
    }
    
    // 被封装的行，如果未截断代表原始行，如果截断代表截断后的行，注意截断行是人为创建的
    private var _lineRef:CTLine?
    var lineRef:CTLine? {
        set {
            _lineRef = newValue
        }
        get {
            return _lineRef
        }
    }
    
    // 原始行坐标,UIKit坐标系统
    var originalLineRect:CGRect? {
        get {
            guard let originalBaselineOrigin = self.originalBaselineOrigin else { return nil }
            guard let originalFontMetrics = self.originalFontMetrics else { return nil }
            let lineWidth = self.lineWidth
            
            return CGRect.init(x: originalBaselineOrigin.x, y: originalBaselineOrigin.y - originalFontMetrics.ascent, width: lineWidth, height: YHAsyncFontMetricsGetLineHeight(originalFontMetrics))
        }
    }
    
    // 行坐标，是经过基线等调整后的结果，UIKit坐标系统
     var lineRect:CGRect? {
        get {
            guard let baselineOrigin = self.baselineOrigin else { return nil }
            guard let fontMetrics = self.fontMetrics else { return nil }
            let lineWidth = self.lineWidth
            
            return CGRect.init(x: baselineOrigin.x,
                               y: baselineOrigin.y - fontMetrics.ascent,
                               width: lineWidth,
                               height: YHAsyncFontMetricsGetLineHeight(fontMetrics))

        }
    }
    
    fileprivate var rangeLocOffset:NSInteger {
        get {
            guard let _ = self.lineRef else { return 0 }
            guard let originStringRange = self.originStringRange else { return 0 }
            guard let truncatedStringRange = self.truncatedStringRange else { return 0 }
            
            return max(originStringRange.location - truncatedStringRange.location, 0)
        }
    }
    
    // 原始基线原点，UIKit坐标系统
    private(set) var originalBaselineOrigin:CGPoint?
    
    // 基线原点，UIKit坐标系统
    private(set) var baselineOrigin:CGPoint?
    
    // 该行对应的字符Range，截断前的值，例如最后一行是截断的，那么它的Range可能是（12， 10）
    private(set) var originStringRange:NSRange?
    
    // 该行对应的截断字符Range，截断后的值，例如最后一行是截断的，那么它的截断后Range是（0， 10）
    private(set) var truncatedStringRange:NSRange?
    
    // 行原始FontMetrics
    private(set) var originalFontMetrics:YHAsyncFontMetrics?
    
    // 经过基线调校后的FontMetrics
    private(set) var fontMetrics:YHAsyncFontMetrics?
    
    // 删除线对应的Frame
    private(set) var strikeThroughFrames:[CGRect]?
    
    // 标记该行是否是截断行
    private(set) var truncated:Bool = false
    
    /**
     * 计算指定索引位置字符相对于行基线原点的偏移量
     *
     * @param characterIndex 全体字符范围内的字符索引
     *
     * @return 水平偏移量
     */
    
    func offsetXForCharacterAtIndex(_ characterIndex:NSInteger) -> CGFloat {
        guard let lineRef = self.lineRef else { return 0 }
        let locOffset = self.rangeLocOffset
        var characterIndex1 = characterIndex
        characterIndex1 -= min(characterIndex, locOffset)
        
        let offset = CTLineGetOffsetForStringIndex(lineRef, characterIndex1, nil)
    
        return offset
    }
    
    /**
     * 计算指定索引位置字符相对于行基线原点的偏移坐标Point
     *
     * @param characterIndex 全体字符范围内的字符索引
     *
     * @return 水平偏移点的坐标
     */
    
    func baselineOriginForCharacterAtIndex(_ characterIndex:NSInteger) -> CGPoint? {
        var origin = self.baselineOrigin
        
        guard let lineRef = self.lineRef else { return origin }

        let locOffset = self.rangeLocOffset
        
        var characterIndex1 = characterIndex
        characterIndex1 -= min(characterIndex, locOffset)
        
        let offset = CTLineGetOffsetForStringIndex(lineRef, characterIndex1, nil)

        origin?.x += offset

        return origin
    }
    
    /**
     * 计算指定位置对应的字符索引，进而我们可以获取到点击位置的字符
     *
     * @param position 触摸位置
     *
     * @return 字符索引
     */
    
    func characterIndexForBoundingPosition(_ position:CGPoint) -> Int  {
        
        guard var index = self.originStringRange?.location else { return 0 }
        
        guard let lineRef = self.lineRef else { return index }

        index = CTLineGetStringIndexForPosition(lineRef, position)
        
        index += self.rangeLocOffset
        
        return index
    }
    
    /**
     * 遍历当前行中的所有Runs，Runs即当前行中插入的所有文本组件
     *
     * @param block 以block方式回调每个CTRun对应的索引，附加属性参数，对应的字符Range
     *
     */
    
    func enumerateRunsUsingBlock(_ block:runsUsingBlock?) {
        guard let lineRef = self.lineRef else { return }
        guard let block = block else { return }

        let locOffset = self.rangeLocOffset
        
        let runs = CTLineGetGlyphRuns(lineRef) as NSArray
        for run in runs {
            
            let attributes = CTRunGetAttributes(run as! CTRun) as NSDictionary
            let range = CTRunGetStringRange(run as! CTRun)
            var nsRange = NSRange.init(location: range.location, length: range.length)
            nsRange.location += locOffset
            block(run as! CTRun, attributes, nsRange)
        }

    }
}

extension YHAsyncTextLayoutLine : NSCopying, NSMutableCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init()
        theCopyObj._lineRef = self.lineRef
        theCopyObj.truncated = self.truncated
        theCopyObj.lineWidth = self.lineWidth
        theCopyObj.originalBaselineOrigin = self.originalBaselineOrigin
        theCopyObj.baselineOrigin = self.baselineOrigin
        theCopyObj.originStringRange = self.originStringRange
        theCopyObj.truncatedStringRange = self.truncatedStringRange
        theCopyObj.originalFontMetrics = self.originalFontMetrics
        theCopyObj.fontMetrics = self.fontMetrics
        return theCopyObj
    }
    
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).copy()
        return theCopyObj
    }
}
