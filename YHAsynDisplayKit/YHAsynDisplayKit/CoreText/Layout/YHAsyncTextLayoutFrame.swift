//
//  YHAsyncTextLayoutFrame.swift
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

typealias lineBlock = (_ index:UInt, _ rect:CGRect?, _ range:NSRange?, _ stop:inout Bool)->Void
typealias frameBlock = (_ rect:CGRect?, _ range:NSRange, _ stop: inout Bool) -> Void

public class YHAsyncTextLayoutFrame: NSObject{
    fileprivate weak var textLayout:YHAsyncTextLayout?
    var arrayLines:[YHAsyncTextLayoutLine]?
    var layoutSize:CGSize?
    
    
    required override init() {
        super.init()
    }
    
    /**
     *  根据一个CTFrameRef进行初始化
     *
     *  @param frameRef    CTFrameRef
     *  @param textLayout  WMGTextLayout
     *
     *  @return YHAsyncTextLayoutFrame
     */
    init(_ frameRef:CTFrame?, inTextLayout:YHAsyncTextLayout) {
        super.init()
        self.textLayout = inTextLayout
        self.setupWithCTFrame(frameRef)
    }
    
    func setupWithCTFrame(_ frameRef:CTFrame?) {
        guard let maximumNumberOfLines:UInt = self.textLayout?.maximumNumberOfLines else { return }
        guard let frameRef = frameRef else { return }
        let lines = CTFrameGetLines(frameRef) as NSArray
        let lineCount = lines.count
        
        var originsArray = [CGPoint](repeating: CGPoint.zero, count: lineCount)
        CTFrameGetLineOrigins(frameRef, CFRange.init(location: 0, length: lineCount), &originsArray)
        
        self.arrayLines = [YHAsyncTextLayoutLine]()
        
        for index in 0 ..< lineCount {
            let lineRef = lines[index] as! CTLine
            var truncatedLineRef:CTLine?
            
            if maximumNumberOfLines > 0 {
                if index  == maximumNumberOfLines - 1 {
                    var truncated:Bool = false
                    truncatedLineRef = self.textLayout(self.textLayout, lineRef: lineRef, index: UInt(index), truncated: &truncated)
                    if !truncated {
                        truncatedLineRef = nil
                    }
                } else if index >= maximumNumberOfLines {
                    break
                }
            }
            guard let textLayout = self.textLayout else { continue }
            let line = YHAsyncTextLayoutLine(lineRef, truncatedLineRef: truncatedLineRef, baselineOrigin: originsArray[index], textLayout: textLayout)
            self.arrayLines?.append(line)
            
        }
        self.updateLayoutSize()
    }
    
    fileprivate func updateLayoutSize() {
        var width:CGFloat = 0.0
        var height:CGFloat = 0.0
        
        guard let arrayLines = self.arrayLines else { return }
        
        for layoutLine in arrayLines {
            if let fragmentRect = layoutLine.lineRect {
                height = max(height, fragmentRect.maxY)
                width  = max(width, fragmentRect.maxX)
            }
        }
        
        self.layoutSize = CGSize.init(width: ceil(width), height: ceil(height))
    }
    
    /**
     *  获取一个文字 index 对应的行数
     *
     *  @param characterIndex 文字 index
     *
     *  @return 行的 index
     */
    func lineIndexForCharacterAtIndex(_ characterIndex:UInt) -> UInt {
        guard let arrayLines = self.arrayLines else { return 0 }
        var lineIndex:UInt = 0
        for layoutLine in arrayLines {
            guard let originStringRange = layoutLine.originStringRange else { continue }
            if rangeContainsIndex(originStringRange, characterIndex) && characterIndex != NSMaxRange(originStringRange) {
                lineIndex += 1
            }
        }
        
        return lineIndex
    }
    
    /**
     *  获取某一行 在 layout 中的 frame，并可以返回这一行文字对应的字符串范围
     *
     *  @param index                   行的 index
     *  @param effectiveCharacterRange 这一行文字对应的字符串范围
     *
     *  @return 这一行的 frame，如果 index 无效，将返回 CGRectNull
     */
    
    func lineRectForLineAtIndex(_ index:UInt, effectiveCharacterRange:inout NSRange?) -> CGRect? {
        guard let arrayLines = self.arrayLines else { return nil }
        if index >= arrayLines.count {
            effectiveCharacterRange = NSMakeRange(NSNotFound, 0)
            return nil
        }
        
        let line:YHAsyncTextLayoutLine = arrayLines[Int(index)]
        effectiveCharacterRange = line.originStringRange
        
        return line.lineRect
    }
    
    /**
     *  获取某一文字 index 对应的 行 在 layout 中的 frame，并可以返回这一行文字对应的字符串范围
     *
     *  @param index                   文字的 index
     *  @param effectiveCharacterRange 文字所在行中的文字对应的字符串范围
     *
     *  @return 这一行的 frame，如果 index 无效，将返回 CGRectNull
     */
    func lineRectForCharacterAtIndex(_ index:UInt, effectiveCharacterRange:inout NSRange?) -> CGRect? {
        let lineIndex = self.lineIndexForCharacterAtIndex(index)
        
        return self.lineRectForLineAtIndex(lineIndex, effectiveCharacterRange: &effectiveCharacterRange)
    }
    
    /**
     *  某一字符串范围对应的 frame，如果该范围中包含多行文字，则返回第一行的 frame
     *
     *  @param characterRange 字符串的范围
     *
     *  @return 文字的 frame，如果 range 无效，将返回 CGRectNull
     */
    
    func firstSelectionRectForCharacterRange(_ characterRange:NSRange) -> CGRect? {
        var selectionRect:CGRect?
        
        self.enumerateSelectionRectsForCharacterRange(characterRange) { (rect, lineRange, stop) in
            selectionRect = rect
            stop = true
        }
        
        return selectionRect
    }
    
//    #pragma mark - Result
    /**
     *  遍历行的信息
     *
     *  @param block   传入参数分别为：行的index、行的frame、行中 文字对应的字符串范围
     */
    
    func enumerateLinesUsingBlock(_ block:lineBlock?) {
        guard let block = block else { return }
        guard let arrayLines = self.arrayLines else { return }
        var index:UInt = 0
        for layoutLine in arrayLines {
            var stop:Bool = false
            block(index, layoutLine.lineRect, layoutLine.originStringRange, &stop)
            if stop {
                return
            }
            index += 1
        }
    }
    
    /**
     *  遍历某一字符串范围中文字的 frame 等信息
     *
     *  @param characterRange 字符串范围
     *  @param block          如果文字存在于多行中，会被调用多次。传入参数分别为：文字的 frame、文字对应的字符串范围
     */
    func enumerateEnclosingRectsForCharacterRange(_ characterRange:NSRange, _ block:frameBlock?) {
        guard let block  = block else { return }
        guard let arrayLines = self.arrayLines else { return }
        var stop:Bool = false
        let lineCount = arrayLines.count
        var index:UInt = 0
        for layoutLine in arrayLines {
            guard let lineRange  = layoutLine.originStringRange else { continue }
            guard let lineRect  = layoutLine.lineRect else { continue }

            let lineStartIndex = lineRange.location
            let lineEndIndex = NSMaxRange(lineRange)
            
            let characterStartIndex = characterRange.location
            var characterEndIndex = NSMaxRange(characterRange)
            
            // 如果请求的 range 在当前行之后，直接结束
            if characterStartIndex >= lineEndIndex {
                return
            }
            
            // 如果是最后一行，防止越界
            if index == lineCount - 1 {
                characterEndIndex = min(lineEndIndex, characterEndIndex)
            }
            
            let containsStartIndex = rangeContainsIndex(lineRange, UInt(characterStartIndex))
            let containsEndIndex = rangeContainsIndex(lineRange, UInt(characterEndIndex))
            
            // 一共只有一行
            if containsEndIndex && containsStartIndex {
                if containsEndIndex != containsStartIndex {
                    let startOffset = layoutLine.offsetXForCharacterAtIndex(characterStartIndex)
                    let endOffset = layoutLine.offsetXForCharacterAtIndex(characterEndIndex)
                    var rect = lineRect
                    rect.origin.x += startOffset
                    rect.size.width = endOffset - startOffset
                    
                    block(rect, NSRange.init(location: characterStartIndex, length: characterEndIndex - characterStartIndex),
                          &stop)
                }
                
                
            // 多行时的第一行
            } else if containsStartIndex {
                if characterStartIndex != NSMaxRange(lineRange) {
                    let startOffset = layoutLine.offsetXForCharacterAtIndex(characterEndIndex)
                    var rect = lineRect
                    rect.origin.x += startOffset
                    rect.size.width -= startOffset
                    
                    block(rect, NSRange.init(location: characterStartIndex, length: lineEndIndex - characterStartIndex),
                    &stop)
                }
            }
            // 多行时的最后一行
            else if containsEndIndex {
                let endOffset = layoutLine.offsetXForCharacterAtIndex(characterEndIndex)
                var rect = lineRect
                rect.size.width = endOffset
                
                block(rect, NSRange.init(location: lineStartIndex, length: lineEndIndex - lineStartIndex),
                &stop)
            }
            // 多行时的中间行
            else if rangeContainsIndex(characterRange, UInt(lineRange.location)) {
                block(lineRect, lineRange, &stop)
            }
            
            
            if containsEndIndex {
                stop = true
            }
            
            if stop {
                return
            }
        }
    }
    
    /**
     *  遍历某一字符串范围中文字的 frame 等信息，用于选择区域的绘制等操作
     *
     *  @param characterRange 字符串范围
     *  @param block          如果文字存在于多行中，会被调用多次。传入参数分别为：文字的 frame、文字对应的字符串范围
     *
     *  @return 整个区域的 bounding 区域
     */
    
    func enumerateSelectionRectsForCharacterRange(_ characterRange:NSRange,_ block:frameBlock?) -> CGRect? {
        guard let containerSize = self.textLayout?.size else { return nil }
        var boundingRect:CGRect?
        
        var stop:Bool = false
        self.enumerateEnclosingRectsForCharacterRange(characterRange) { (rect, lineRange, stop) in
            guard var rectNew = rect else { return }
            if NSMaxRange(lineRange) < NSMaxRange(characterRange) {
                rectNew.size.width = containerSize.width - rectNew.minX
            }
            
            if let block = block {
                if let boundingRect = boundingRect {
                    let deltaHeight = rectNew.origin.y - rectNew.maxY
                    rectNew.origin.y -= deltaHeight
                    rectNew.size.height += deltaHeight
                    stop = true
                }
                block(rectNew, characterRange, &stop)
            }
            boundingRect = boundingRect?.union(rectNew)
        }
        
        
        return boundingRect
    }
    
    
    /**
     *  获取某一字符串 index 对应文字在 layout 中的坐标
     *
     *  @param characterIndex 字符串 index
     *
     *  @return layout 中的坐标，取 glyph 的中心点
     */
    
    func locationForCharacterAtIndex(_ characterIndex:UInt) -> CGPoint? {
        guard let rect = self.boundingRectForCharacterRange(NSRange.init(location: Int(characterIndex), length: 1)) else {
            return nil
        }
        
        
        return CGPoint.init(x: rect.midX,y:rect.minY)
    }
    
    /**
     *  获取一个 frame，它包含传入字符串范围中的所有文字
     *
     *  @param characterRange 字符串范围
     *
     *  @return 包含所有文字的 frame
     */
    func boundingRectForCharacterRange( _ characterRange:NSRange) -> CGRect? {
        
        return self.enumerateSelectionRectsForCharacterRange(characterRange, nil)
    }
    
    /**
     *  获取序号为index的CTLine的起始点坐标
     *
     *  @param index CTLine的序号
     *
     *  @return CTLine的位置
     */
    func positionForLinesAtIndex(_ index:UInt) -> CGPoint? {
        let i = Int(index)
        guard let arrayLines = self.arrayLines else { return nil }
        if arrayLines.count > i {
            let line = arrayLines[i]
            return line.baselineOrigin
        }
        return nil
    }
    
//    #pragma mark - HitTest
    /**
     *  获取一个区域中包含的文字对应的字符串范围
     *
     *  @param bounds 要查询的区域
     *
     *  @return 字符串范围
     */
    func characterRangeForBoundingRect(_ bounds:CGRect) -> NSRange? {
        guard let layoutSize = self.layoutSize else { return nil}
        var topLeftPoint = bounds.origin
        var bottomRightPoint = CGPoint.init(x: bounds.maxX, y: bounds.maxY)
        // 将 bounds 限制在有效区域内
        topLeftPoint.y = min(2, topLeftPoint.y)
        bottomRightPoint.y = max(bottomRightPoint.y, layoutSize.height - 2)
        
        let start = Int(self.characterIndexForPoint(topLeftPoint))
        let end = Int(self.characterIndexForPoint(bottomRightPoint))
        
        return NSRange.init(location: start, length: end - start)
    }
    
    /**
     *  获取某一坐标上的文字对应的字符串 index
     *
     *  @param point 坐标点
     *
     *  @return 字符串 index
     */
    func characterIndexForPoint(_ point:CGPoint) -> UInt {
        guard let string = self.textLayout?.attributedString?.string else { return 0 }
        let stringLength = (string as NSString).length
        guard let lines = self.arrayLines else { return 0}
        let lineCount = lines.count
        
        var previousLineY:CGFloat = 0
        var pointNex = point
        
        for i in 0 ..< lineCount {
            let line = lines[i]
            guard let fragmentRect = line.lineRect else { continue }
            
            // 在第一行之上
            if i == 0 && pointNex.y < fragmentRect.minY {
                return 0
            }
            
            // 在最后一行之下
            if i == lineCount - 1 && pointNex.y > fragmentRect.maxY {
                return UInt(stringLength)
            }

            // 命中！
            if pointNex.y > previousLineY && pointNex.y <= fragmentRect.maxY {
                guard let baselineOrigin = line.baselineOrigin else { continue }
                pointNex.x -= baselineOrigin.x
                pointNex.y -= baselineOrigin.y
                
                var index = line.characterIndexForBoundingPosition(pointNex)
                
                guard let stringRange = line.originStringRange else { continue }
                if index == NSMaxRange(stringRange) && index > 0 {
                    let unichar = (string as NSString).character(at: index - 1)
                    let unicharString = "\(unichar)"
                    if  unicharString == "\\n" {
                        index -= 1
                    }
                }
                return UInt(index)
            }
        }
        
        
        return 0
    }

    fileprivate func textLayout(_ textLayout:YHAsyncTextLayout?, lineRef:CTLine?, index:UInt, truncated:inout Bool) -> CTLine? {
        guard let textLayout = textLayout else {
            truncated = false
            return nil
        }
        guard let lineRef = lineRef else {
            truncated = false
            return nil
        }
        let stringRange = CTLineGetStringRange(lineRef)
        if stringRange.length == 0 {
            truncated = false
            return lineRef
        }
        
        var truncateWidth = textLayout.size.width
        let delegateMaxWidth = self.textLayout(textLayout, maximumWidthForTruncatedLine: lineRef, atIndex: index)
        
        var needsTruncate = false
        
        if delegateMaxWidth < truncateWidth && delegateMaxWidth > 0 {
            let lineWidth = CTLineGetTypographicBounds(lineRef, nil, nil, nil)
            if  CGFloat(lineWidth) > delegateMaxWidth {
                truncateWidth = delegateMaxWidth
                needsTruncate = true
            }
        }
        
        if !needsTruncate {
            if let stringLength = textLayout.attributedString?.length {
               if stringRange.location + stringRange.length < stringLength {
                    needsTruncate = true
                }
            }
        }
        
        if !needsTruncate {
            truncated = false
            return lineRef
        }
        
        guard let attributedString = textLayout.attributedString else {
            truncated = false
            return nil
        }
        
        // Get correct truncationType and attribute position
        var truncationType:CTLineTruncationType = CTLineTruncationType.end
        let truncationAttributePosition = stringRange.location + (stringRange.length - 1)
        
        // Get the attributes and use them to create the truncation token string
        var attrs:[NSAttributedString.Key : Any] = attributedString.attributes(at: truncationAttributePosition, effectiveRange: nil)
        
        attrs = attrs.filter({ (arg0) -> Bool in
            let (key, value) = arg0
            if key == kCTFontAttributeName as NSAttributedString.Key {
                return true
            } else if key == kCTFontAttributeName as NSAttributedString.Key {
                return true
            } else if key == kCTFontAttributeName as NSAttributedString.Key {
                return true
            } else if key == NSAttributedString.Key.init(YHAsyncTextKeyAttributeName.DefaultForegroundColor) {
                return true
            }
            
            return false
        })
        
        // Filter all NSNull values
        var tokenAttributes = [NSAttributedString.Key : Any]()
        for key in attrs.keys {
            if let value = attrs[key] {
                tokenAttributes[key] = value
            }
        }
        
        let cgColor = tokenAttributes[NSAttributedString.Key.init(YHAsyncTextKeyAttributeName.DefaultForegroundColor)]
        tokenAttributes[NSAttributedString.Key.init(kCTForegroundColorAttributeName as String)] = cgColor
        
        // 如果设置了truncationString，则用自定义的
        var tokenString:NSAttributedString = NSAttributedString.init(string: YHAsyncMacroConfigKey.EllipsisCharacter, attributes: tokenAttributes)
        
        if let truncationString = self.textLayout?.truncationString {
            tokenString = truncationString
        }
         
        let truncationToken = CTLineCreateWithAttributedString(tokenString)
        
        // Append truncationToken to the string
        // because if string isn't too long, CT wont add the truncationToken on it's own
        // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
        let truncationString:NSAttributedString = attributedString.attributedSubstring(from: NSRange.init(location: stringRange.location, length: stringRange.length))
        let mutableTruncationString = NSMutableAttributedString.init(attributedString: truncationString)

        if stringRange.length > 0 {
            // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
            let lastCharacter = (truncationString.string as NSString).character(at: stringRange.length - 1)
            
            if NSMutableCharacterSet.newline().characterIsMember(lastCharacter) {
                mutableTruncationString.deleteCharacters(in: NSRange.init(location: stringRange.length - 1, length: 1))
            }
        }
        
        mutableTruncationString.append(tokenString)
        let truncationLine = CTLineCreateWithAttributedString(mutableTruncationString)
        
        var truncatedLine = CTLineCreateTruncatedLine(truncationLine, Double(truncateWidth), truncationType, truncationToken)
        if truncatedLine == nil {
            truncatedLine = truncationToken
        }
        
//        if truncated {
            truncated = true
//        }
        
        return truncatedLine
    }
    
    func textLayout(_ textLayout:YHAsyncTextLayout?, maximumWidthForTruncatedLine lineRef:CTLine?, atIndex index:UInt) -> CGFloat{
        
        if let delegate = textLayout?.delegate  {
            if delegate.responds(to: #selector(YHAsyncTextLayoutDelegate.textLayout(_:truncatedLine:atIndex:))) {
                let width = delegate.textLayout(textLayout, truncatedLine: lineRef, atIndex: index)
                return width
            }
        }
        
        if let width = textLayout?.size.width {
            return width
        }
        
        return 0
    }
    
//    #pragma mark - Private
    func rangeContainsIndex(_ range:NSRange, _ index:UInt) -> Bool {
        let a:Bool = index >= range.location
        let b:Bool = index <= (range.location + range.length)
        return a && b
    }
}

extension YHAsyncTextLayoutFrame: NSCopying, NSMutableCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init()
        theCopyObj.textLayout = self.textLayout
        theCopyObj.arrayLines = self.arrayLines?.map({ $0.copy() as! YHAsyncTextLayoutLine
        })
        theCopyObj.layoutSize = self.layoutSize
        return theCopyObj
    }
    
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).copy()
        return theCopyObj
    }
}
