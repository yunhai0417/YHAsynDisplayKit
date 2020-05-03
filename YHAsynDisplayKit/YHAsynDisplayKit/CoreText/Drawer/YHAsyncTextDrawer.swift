//
//  YHAsyncTextDrawer.swift
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


import UIKit
import Foundation
import CoreText
import CoreGraphics


public protocol YHAsyncTextDrawerDelegate: NSObjectProtocol {
    
    /**
    *  textAttachment 渲染的回调方法，
    *  delegate 可以通过此方法定义 Attachment 的样式，具体显示的方式可以是绘制到 context 或者添加一个自定义 View
    *
    *  @param textDrawer   执行文字渲染的 textDrawer
    *  @param att          需要渲染的 TextAttachment
    *  @param frame        建议渲染到的 frame
    *  @param context      当前的 CGContext
    */
    
    func textDrawer(_ textDrawer:YHAsyncTextDrawer, attachment replace:YHAsyncTextAttachment, rect frame:CGRect, _ context:CGContext)
}

public protocol YHAsyncTextDrawerEventDelegate: NSObjectProtocol {
    /**
    *  返回 textDrawer 处理事件时所基于的 view，用于确定坐标系等，必须
    *
    *  @param textDrawer 查询的 textDrawer
    *
    *  @return 处理事件时基于的 view
    */
    
    func contextViewForTextDrawer(_ textDrawer:YHAsyncTextDrawer) -> UIView
    
    /**
    *  返回定义 textDrawer 可点击区域的数组
    *
    *  @param textDrawer 查询的 textDrawer
    *
    *  @return 由 (id<WMGTextActiveRange>) 对象组成的数组
    */
    
    func activeRangesForTextDrawer(_ textDrawer:YHAsyncTextDrawer) -> [YHAsyncTextActiveRange]?
    
    /**
    *  响应对一个 activeRange 的点击事件
    *
    *  @param textDrawer 响应事件的 textDrawer
    *  @param activeRange  响应的 activeRange
    */
    
    func textDrawer(_ textDrawer:YHAsyncTextDrawer, didPress activeRange:YHAsyncTextActiveRange)
    
    /**
    *  activeRange点击的 高亮事件
    *
    *  @param textDrawer 响应事件的 textDrawer
    *  @param activeRange  响应的 activeRange
    */

    func textDrawer(_ textDrawer:YHAsyncTextDrawer, didHighlighted activeRange:YHAsyncTextActiveRange,frame rect:CGRect)
    
    /**
    *  返回 textDrawer 是否要与一个 activeRange 进行交互，如点击操作
    *
    *  @param textDrawer 查询的 textDrawer
    *  @param activeRange  是否要与此 activeRange 进行交互
    *
    *  @return 是否与 activeRange 进行交互
    */
    
    func textDrawer(_ textDrawer:YHAsyncTextDrawer, shouldInteract activeRange:YHAsyncTextActiveRange) -> Bool
}

/*
文本绘制器类是框架核心类，混排图文的绘制、size计算都依赖文本绘制器实现
*/

public typealias YHAsyncTextDrawerShouldInterruptBlock = () -> Bool

public class YHAsyncTextDrawer: UIResponder {

    // 绘制原点，一般情况下，经过预排版之后，通过WMGTextDrawer的Frame设置，仅供框架内部使用，请勿直接操作
    var drawOrigin:CGPoint?
    private var drawing:Bool = false
    
    // 文本绘制器的绘制起点和绘制区域的定义，Frame会被拆解成两部分，origin决定绘制起点，size决定绘制区域大小
    public func setFrame(_ frame:CGRect) {

        if self.drawing && frame.size.equalTo(self.getTextLayout().size) {
            debugPrint("draw_error")
        }
        
        self.drawOrigin = frame.origin
        
        if self.getTextLayout().heightSensitiveLayout {
            self.textLayout?.size = frame.size
        } else {
            let height = CGFloat(ceilf(Float((frame.size.height * 1.1) / 100000) * 100000))
            self.textLayout?.size = CGSize.init(width: frame.size.width, height: height)
        }
    }
    
    public func getFrame() -> CGRect? {
        guard let drawOrigin = self.drawOrigin else { return nil }
        guard let textLayoutSize = self.textLayout?.size else { return nil }
        return CGRect.init(x: drawOrigin.x, y: drawOrigin.y, width: textLayoutSize.width, height: textLayoutSize.height)
    }
    
    // CoreText排版模型封装
    fileprivate var textLayout:YHAsyncTextLayout?
    public func getTextLayout() -> YHAsyncTextLayout {
        if let textLayout = self.textLayout {
            return textLayout
        }
        let textLayout = YHAsyncTextLayout.init()
            textLayout.heightSensitiveLayout = true
        self.textLayout = textLayout
        return textLayout
    }
    
    // 文本绘制器的代理
    fileprivate weak var _delegate:YHAsyncTextDrawerDelegate?
    public var delegate:YHAsyncTextDrawerDelegate? {
        set {
            _delegate = newValue
//            let selector = #selector(YHAsyncTextDrawerDelegate.textDrawer(_:attachment:rect:_:))
//            _delegateHas.placeAttachment = _delegate?.responds(to: selector) ?? false
        }
        get {
            return _delegate
        }
    }
    
    // 文本绘制器的事件代理，用以处理混排图文中的可点击响应
    fileprivate weak var _eventDelegate:YHAsyncTextDrawerEventDelegate?
    public var eventDelegate:YHAsyncTextDrawerEventDelegate? {
        set {
            _eventDelegate = newValue
        }
        get {
            return _eventDelegate
        }
    }
    
    
    //Event
    // 记录上次touch end时候的timestamp，否则调用2次touch ended
    var _lastTouchEndedTimeStamp:TimeInterval = 0
    var _delegateHas = YHAsyncTextDrawerDelegateHas()
    var _eventDelegateHas = YHAsyncTextDrawerEventDelegateHas()
    var _touchesBeginPoint:CGPoint?
    // 正在响应点击的激活区，每一个可点击区域都被定义成了激活区
    public weak var pressingActiveRange:YHAsyncTextActiveRange?
    // 已保存的点击激活区
    public weak var savedPressingActiveRange:YHAsyncTextActiveRange?
    
    /**
    *  文本绘制器的基本绘制方法，绘制到当前上下文中
    */
    func draw() {
        if let context = UIGraphicsGetCurrentContext() {
            self.drawInContext(context)
        } else {
            debugPrint("context error")
        }
        
    }
    
    /**
    *  将文本绘制器裹挟的内容绘制到指定上下文中
    *
    *  @param ctx      当前的 CGContext
    */
    func drawInContext(_ ctx:CGContext) {
        self.drawInContext(ctx, shouldInterrupt: nil)
    }
    
    /**
    *  将文本绘制器裹挟的内容绘制到指定上下文中，同时通过block控制中断
    *  中断意味着可以终止绘制流程，但不是一定会终止，这是由于多线程并发决定的，可以参考NSOperation的cancel方法的理念理解
    *
    *  @param ctx        当前的 CGContext
    *  @param block      中断block
    *
    */
    
    func drawInContext(_ ctx:CGContext, shouldInterrupt block:YHAsyncTextDrawerShouldInterruptBlock?) {
        self.drawInContext(ctx, visible: nil, attachments: true, shouldInterrupt: block)
    }
    
    /**
    *  将文本绘制器裹挟的内容绘制到指定上下文中，同时通过block控制中断
    *  中断意味着可以终止绘制流程，但不是一定会终止，这是由于多线程并发决定的，可以参考NSOperation的cancel方法的理念理解
    *
    *  @param ctx                      当前的 CGContext
    *  @param visibleRect              可见区域
    *  @param replaceAttachments       是否替换组件
    *  @param block                    中断block
    *
    */
    
    public func drawInContext(_ inCtx:CGContext?, visible visibleRect:CGRect?, attachments replace:Bool, shouldInterrupt interruptBlock:YHAsyncTextDrawerShouldInterruptBlock?) {
        guard let ctx = inCtx else { return }
        self.drawing = true
        
        let textLayout = self.getTextLayout()
        guard let drawingOrigin = self.drawOrigin else { return }
        let drawingSize = textLayout.size
        
        let partialDrawing:Bool = visibleRect != nil
        
        //interrupt_if_needed
        if let block = interruptBlock {
            if block() {
                self.drawing = false
                return
            }
        }
        
        guard let layoutFrame:YHAsyncTextLayoutFrame = textLayout.layoutFrame?.copy() as? YHAsyncTextLayoutFrame else
        {
            return
        }
        
        //interrupt_if_needed
        if let block = interruptBlock {
            if block() {
                self.drawing = false
                return
            }
        }
        
        if YHAsyncTextDrawer.self.debugModeEnabled() {
            self.debugModeDrawLineFramesWithLayoutFrame(layoutFrame, ctx)
        }
        
        //interrupt_if_needed
        if let block = interruptBlock {
            if block() {
                self.drawing = false
                return
            }
        }
        
        if let pressingActiveRange = self.pressingActiveRange, let characterRange = pressingActiveRange.range {
            
            ctx.saveGState()
            
            layoutFrame.enumerateEnclosingRectsForCharacterRange(characterRange) { (rect, characterRange, stop) in
                guard let rect = rect else { return }
                let rectNew = self.convertRectFromLayout(rect, drawingOrigin)
                self.drawHighlightedBackgroundForActiveRange(pressingActiveRange, rect, ctx)
            }
            ctx.restoreGState()
        }
        
        //interrupt_if_needed
        if let block = interruptBlock {
            if block() {
                self.drawing = false
                return
            }
        }
        
        ctx.saveGState()
        ctx.textMatrix = CGAffineTransform.identity
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.translateBy(x: 0, y: -textLayout.size.height)
        
        if let block = interruptBlock {
            if block() {
                ctx.restoreGState()
                self.drawing = false
                return
            }
        }
        
        guard let arrayLines = layoutFrame.arrayLines else {
            ctx.restoreGState()
            return
        }
        
        for line in arrayLines {
            guard var framentRect:CGRect = line.lineRect else { continue }
            guard let framentRect1 = self.convertRectFromLayout(framentRect, drawingOrigin) else { continue }
            
            if partialDrawing {
                if let vRect = visibleRect {
                    if !framentRect.intersects(vRect) {
                        continue
                    }
                }
            }
            
            if let lineRef = line.lineRef, var lineOrigin = line.baselineOrigin {
                
                lineOrigin.y = drawingSize.height - lineOrigin.y
                lineOrigin.y -= drawingOrigin.y
                lineOrigin.x += drawingOrigin.x
                
                ctx.textPosition = CGPoint(x: lineOrigin.x, y: lineOrigin.y)
                
                //绘制位置到context
                CTLineDraw(lineRef, ctx)
            }
            
            
            
            let strikeColor = UIColor.init(red:  ((CGFloat)((0x999999 & 0xFF0000) >> 16)) / 255.0,
                                           green: ((CGFloat)((0x999999 & 0xFF00) >> 8)) / 255.0,
                                           blue: ((CGFloat)(0x999999 & 0xFF)) / 255.0,
                                           alpha: 1.0)
            
            if let strikeThroughFrames = line.strikeThroughFrames {
                for rectValue in strikeThroughFrames {
                    var strikeFrame = rectValue
                    strikeFrame.origin.y = drawingSize.height - strikeFrame.origin.y
                    strikeFrame.origin.y -= drawingOrigin.y
                    strikeFrame.origin.x += drawingOrigin.x
                    
                    ctx.saveGState()
                    ctx.textPosition = CGPoint(x: strikeFrame.origin.x, y: strikeFrame.origin.y)
                    ctx.move(to:CGPoint(x: strikeFrame.origin.x, y: strikeFrame.origin.y))
                    ctx.addLine(to: CGPoint(x: strikeFrame.origin.x + strikeFrame.size.width , y: strikeFrame.origin.y))
                    ctx.setStrokeColor(strikeColor.cgColor)
                    ctx.strokePath()
                    ctx.restoreGState()
                }
            }
            
            if let block = interruptBlock {
                if block() {
                    ctx.restoreGState()
                    self.drawing = false
                    return
                }
            }
        }
        
        ctx.restoreGState()
        
        if replace {
            self.drawAttachmentsInContext(ctx, shouldInterruptBlock: interruptBlock)
        }
        self.drawing = false
        
    }
    
    
    //绘制附件图片
    fileprivate func drawAttachmentsInContext(_ ctx:CGContext, shouldInterruptBlock shouldInterrupt:YHAsyncTextDrawerShouldInterruptBlock?) {
        let scale = UIScreen.main.scale
        guard let offset = self.drawOrigin else { return }
        guard let arrayLines = self.getTextLayout().layoutFrame?.arrayLines else { return }
        for line in arrayLines {
            line.enumerateRunsUsingBlock { (_, attributes, characterRange) in
                if let attachment = attributes.object(forKey: YHAsyncMacroConfigKey.TextAttachmentAttributeName) as? YHAsyncTextAttachment {
                    guard let characterOrigin = line.baselineOriginForCharacterAtIndex(characterRange.location) else {
                        return
                    }
                    guard let metrics = attachment.baselineFontMetrics else { return }
                    guard let degeInset = attachment.edgeInsets else { return }
                    guard let attachmentSize = attachment.size else { return }
                    
                    var frame = CGRect.init(x: characterOrigin.x + degeInset.left,
                                            y: characterOrigin.y + metrics.descent + metrics.leading - degeInset.bottom - attachmentSize.height,
                                            width: attachmentSize.width,
                                            height: attachmentSize.height)
                    frame.origin.x += offset.x
                    frame.origin.y += offset.y
                    
                    frame.origin.x = round(frame.origin.x * scale) / scale
                    frame.origin.y = round(frame.origin.y * scale) / scale
                    
                    if self._delegateHas.placeAttachment {
                        self._delegate?.textDrawer(self, attachment: attachment, rect: frame, ctx)
                    } else if attachment.type == YHAsyncAttachmentType.StaticImage {
                        if let content = attachment.contents as? String {
                            UIGraphicsPushContext(ctx)
                            let image = UIImage(named: content)
                            image?.draw(in: frame)
                            UIGraphicsPopContext()
                        }
                        if let content = attachment.contents as? UIImage {
                            UIGraphicsPushContext(ctx)
                            content.draw(in: frame)
                            UIGraphicsPopContext()
                        }
                    }

                }
                
                var image1 = UIGraphicsGetImageFromCurrentImageContext()

            }
            if let shouldInterrupt = shouldInterrupt {
                if shouldInterrupt() {
                    return
                }
            }
        }
        
    }
    
    fileprivate func drawHighlightedBackgroundForActiveRange( _ activeRange:YHAsyncTextActiveRange, _ rect:CGRect, _ context:CGContext) {
        
        if YHAsyncTextDrawer.self.debugModeEnabled() {
            let newRect = rect.integral
            let color = UIColor.blue
            color.set()
            context.setShadow(offset: CGSize.init(width: 0, height: 0), blur: 8, color: color.cgColor)
            YHAsynContextAssiant.currentContextFillRoundRect(context, rect: newRect, radius: 10)
        }
        
        if _eventDelegateHas.didHighlightedActiveRange {
            _eventDelegate?.textDrawer(self, didHighlighted: activeRange, frame: rect)
        }
    }
    
    //MARK: - Event Handle
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let contextView = self.eventDelegateContextView() else { return }
        guard let location = touches.first?.location(in: contextView) else { return }
        guard let drawOrigin = drawOrigin else { return }
        let layoutLocation = self.convertPointToLayout(location, drawOrigin)
        
        if let activeRanges = self.eventDelegateActiveRanges() {
            if let activeRange = self.rangeInRanges(activeRanges, forLayoutLocation: layoutLocation) {
                self.pressingActiveRange = activeRange
                contextView.setNeedsDisplay()
            }
        }
        
        _touchesBeginPoint = location
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let contextView = self.eventDelegateContextView() else { return }
        let respondingRadius:CGFloat = 50
        guard let location = touches.first?.location(in: contextView) else { return }

        guard let touchesBeginPoint = _touchesBeginPoint else { return }
        let movedDistance:CGFloat = CGFloat(sqrt(pow((location.x - touchesBeginPoint.x), 2.0) + pow((location.y - touchesBeginPoint.y), 2.0)))
        
        let response = movedDistance <= respondingRadius
        if let pressingActiveRange = self.pressingActiveRange {
            if !response {
                self.savedPressingActiveRange = self.pressingActiveRange
                self.pressingActiveRange = nil
                
                contextView.setNeedsDisplay()
            }
        }
        
        if let savedPressingActiveRange = self.savedPressingActiveRange {
            if response {
                self.pressingActiveRange = self.savedPressingActiveRange
                self.savedPressingActiveRange = nil
                
                contextView.setNeedsDisplay()
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _lastTouchEndedTimeStamp != event?.timestamp {
            self.savedPressingActiveRange = nil
            if let timestamp = event?.timestamp {
                _lastTouchEndedTimeStamp = timestamp
            }
            if let pressingActiveRange = self.pressingActiveRange {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.eventDelegateDidPressActiveRange(pressingActiveRange)
                }
            }
            
            _touchesBeginPoint = CGPoint.zero
            
            // 若用户点击速度过快，hitRange高亮状态还未绘制又取消高亮会导致没有高亮效果
            // 故延迟执行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.pressingActiveRange = nil
                self.eventDelegateContextView()?.setNeedsDisplay()
            }
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.savedPressingActiveRange = nil
        if let _ = self.pressingActiveRange {
            self.pressingActiveRange = nil
            self.eventDelegateContextView()?.setNeedsDisplay()
        }
    }
    
    
}
