//
//  YHAsyncMixedView.swift
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

public enum YHAsyncTextVerticalAlignment:NSInteger {
    case top                = 1
    case center             = 2
    case bottom             = 3
    case centerCompatility  = 4
}

public enum YHAsyncTextHorizontalAlignment:NSInteger {
    case left   = 1
    case center = 2
    case right  = 3
}

struct YHAsyncMixedViewKey {
    static let attributedItem           = "yh_async_attributeditem_key"
    static let horizontalAlignment      = "yh_async_horizontalalignment_key"
    static let verticalAlignment        = "yh_async_verticalalignment_key"

}

public class YHAsyncMixedView: YHAsyncCanvasControl {

    fileprivate var _drawerDates:[YHAsyncVisionObject] = [YHAsyncVisionObject]()
    public var drawerDates:[YHAsyncVisionObject] {
        set {
            if _drawerDates != newValue {
                _drawerDates = newValue
                self.setNeedsDisplay()
            }
        }
        get {
            return _drawerDates
        }
    }
    
    // 水平对齐方式
    fileprivate var _horizontalAlignment:YHAsyncTextHorizontalAlignment = YHAsyncTextHorizontalAlignment.left
    public var horizontalAlignment:YHAsyncTextHorizontalAlignment {
        set {
            if _horizontalAlignment != newValue {
                _horizontalAlignment = newValue
                self.setNeedsDisplayAsync()
            }
        }
        get {
            return _horizontalAlignment
        }
    }
    
    // 垂直对齐方式
    fileprivate var _verticalAlignment:YHAsyncTextVerticalAlignment = YHAsyncTextVerticalAlignment.top
    public var verticalAlignment:YHAsyncTextVerticalAlignment  {
        set {
            if _verticalAlignment != newValue {
                _verticalAlignment = newValue
                self.setNeedsDisplayAsync()
            }
        }
        get {
            return _verticalAlignment
        }
    }

    // 行数，default is 0
    fileprivate var _numberOfLines:NSInteger = 0
    public var numberOfLines:NSInteger {
        set {
            if _numberOfLines != newValue {
                _numberOfLines = newValue
                self.textDrawer.getTextLayout().maximumNumberOfLines = UInt(newValue)
                self.pendingAttachmentUpdates = true
                self.setNeedsDisplay()
            }
        }
        get {
            return _numberOfLines
        }
    }
    
    // 待绘制内容
    fileprivate var _attributedItem:YHAsyncMutableAttributedItem?
    public var attributedItem:YHAsyncMutableAttributedItem? {
        set {
            if let newValue = newValue {
                if newValue != _attributedItem {
                    _attributedItem = newValue
                    self.setNeedsDisplayAsync()
                    self.pendingAttachmentUpdates = true
                }
                
            } else {
                if _attributedItem != nil {
                    _attributedItem = nil
                    self.setNeedsDisplayAsync()
                    self.pendingAttachmentUpdates = true
                }
            }
        }
        get {
            return _attributedItem
        }
    }
    
    fileprivate var pendingAttachmentUpdates:Bool = false
    
    fileprivate lazy var arrayAttachments:[YHAsyncTextAttachment] = {
        let array = [YHAsyncTextAttachment]()
        return array
    }()
    
    fileprivate lazy var lock:NSRecursiveLock = {
        let lock = NSRecursiveLock.init()
        return lock
    }()
    
    fileprivate lazy var textDrawer:YHAsyncTextDrawer = {
        let drawer = YHAsyncTextDrawer.init()
            drawer.frame = CGRect.zero
            drawer.delegate = self
            drawer.eventDelegate = self
        return drawer
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFrame(_ frame:CGRect) {
        if !frame.equalTo(self.frame) {
            self.frame = frame
            self.setNeedsDisplayAsync()
            self.pendingAttachmentUpdates = true
        }
    }
    
    //MARK: - Drawing
    public override func currentDrawingUserInfo() -> [String : Any] {
        var userInfo = [String : Any]()
        let dic = super.currentDrawingUserInfo()
        userInfo.merge(dic) { (current, _) in current }
        
        if let resultSting = self.attributedItem?.resultString {
            userInfo[YHAsyncMixedViewKey.attributedItem] = resultSting
        }
        
        userInfo[YHAsyncMixedViewKey.horizontalAlignment] = self.horizontalAlignment
        userInfo[YHAsyncMixedViewKey.verticalAlignment] = self.verticalAlignment
        
        
        return userInfo
    }
    
    public override func drawInRect(_ rect: CGRect, context: CGContext?, asynchronously: Bool, userInfo: [String : Any]?) -> Bool {
        super.drawInRect(rect, context: context, asynchronously: asynchronously, userInfo: userInfo)
        let initialDrawingCount = self.drawingCount
        
        guard let resultString = userInfo?[YHAsyncMixedViewKey.attributedItem] as? NSAttributedString else {
            return true
        }
        
        self.textDrawer.frame = rect
        self.textDrawer.getTextLayout().attributedString = resultString
        
        guard let layoutFrame = self.textDrawer.getTextLayout().layoutFrame else {
            return true
        }
        
        guard let layoutSize = layoutFrame.layoutSize else {
            return true
        }
        
        if let horAlignment = userInfo?[YHAsyncMixedViewKey.horizontalAlignment] as? YHAsyncTextHorizontalAlignment {
            if horAlignment == YHAsyncTextHorizontalAlignment.right {
                if var point = self.textDrawer.drawOrigin {
                    point.x = rect.size.width - layoutSize.width
                    self.textDrawer.drawOrigin = point
                }
            } else if horAlignment == YHAsyncTextHorizontalAlignment.center {
                if var point = self.textDrawer.drawOrigin {
                    point.x = (rect.size.width - layoutSize.width) * 0.5
                    self.textDrawer.drawOrigin = point
                }
            }
        }
        
        if let verAlignment = userInfo?[YHAsyncMixedViewKey.verticalAlignment] as? YHAsyncTextVerticalAlignment {
            if verAlignment == YHAsyncTextVerticalAlignment.bottom {
                if var point = self.textDrawer.drawOrigin {
                    point.y = rect.size.height - layoutSize.height
                    self.textDrawer.drawOrigin = point
                }
            } else if verAlignment == YHAsyncTextVerticalAlignment.center {
                if var point = self.textDrawer.drawOrigin {
                    point.y = (rect.size.height - layoutSize.height) * 0.5
                    self.textDrawer.drawOrigin = point
                }
            } else if verAlignment == YHAsyncTextVerticalAlignment.centerCompatility {
                if var point = self.textDrawer.drawOrigin {
                    let offset:CGFloat = 1
                    point.y = (rect.size.height - layoutSize.height) * 0.5
                    point.y -= offset
                    self.textDrawer.drawOrigin = point
                }
            }
        }
        
        var visibleRect:CGRect?

        if let ctx = context {
            self.textDrawer.drawInContext(ctx, visible: visibleRect, attachments: self.pendingAttachmentUpdates) { () -> Bool in
                if initialDrawingCount != self.drawingCount {
                    return true
                }
                return false
            }
        }
        
        return true
    }
    
    public override func drawingDidFinishAsynchronously(_ asynchronously: Bool, success: Bool) {
        if !success {
            return
        }
        self.lock.lock()
        var i:Int = 0
        while i < self.arrayAttachments.count {
            if i >= 0 && i < self.arrayAttachments.count {
                let attachment = self.arrayAttachments[i]
                if attachment.type == YHAsyncAttachmentType.StaticImage {
                    guard let asyncImage = attachment.contents as? YHAsyncImage else { continue }
                    // TODO: 图片下载流程
                    guard let downLoadUrl = asyncImage.downloadUrl else { continue }
                    asyncImage.loadImageWithUrl(downLoadUrl, inoptions: [], inprogress: nil) { [weak self] (image, error, cacheType, imageURL) in
                        self?.lock.lock()
                        if self?.arrayAttachments.contains(attachment) ?? false {
                            self?.arrayAttachments.remove(at: i)
                            i = i - 1
                            self?.setNeedsDisplay()
                        }
                        self?.lock.unlock()
                    }
                }
            }
            i = i + 1
        }
        self.lock.unlock()
        
    }
    
    //MARK: - Event Handing
    func shouldDisableGestureRecognizerInLocation(_ location:CGPoint) -> Bool {
        guard let arrayAtts = self.attributedItem?.arrayAttachments else {
            return false
        }
        for attachment in arrayAtts {
            if attachment.type == YHAsyncAttachmentType.StaticImage && attachment.responseEvent{
                if let result = attachment.layoutFrame?.contains(location) {
                    return result
                }
            }
        }
        
        return false
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textDrawer.touchesBegan(touches, with: event)
        
        if self.textDrawer.pressingActiveRange == nil {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textDrawer.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textDrawer.touchesMoved(touches, with: event)
        if self.textDrawer.pressingActiveRange == nil {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textDrawer.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}



// MARK: - YHAsyncTextDrawerDelegate

extension YHAsyncMixedView:YHAsyncTextDrawerDelegate {
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, attachment replace: YHAsyncTextAttachment, rect frame: CGRect, _ context: CGContext) {
        if replace.type != YHAsyncAttachmentType.StaticImage {
            return
        }
        
        if let imageName = replace.contents as? String {
            UIGraphicsPushContext(context)
            let image = UIImage.init(named: imageName)
            image?.draw(in: frame)
            UIGraphicsPopContext()
        }
        
        if let image = replace.contents as? UIImage {
            UIGraphicsPushContext(context)
            image.draw(in: frame)
            UIGraphicsPopContext()
        }
        
        if let yhimage = replace.contents as? YHAsyncImage {
            if let image = yhimage.image {
                UIGraphicsPushContext(context)
                yhimage.image?.draw(in: frame)
                UIGraphicsPopContext()
            } else {
                if let placeholderName = yhimage.placeholderName {
                    if !placeholderName.isEmpty {
                        UIGraphicsPushContext(context)
                        let image = UIImage.init(named: placeholderName)
                        image?.draw(in: frame)
                        UIGraphicsPopContext()
                    }
                }
            }
            
            if let downloadUrl = yhimage.downloadUrl {
                if !downloadUrl.isEmpty {
                    replace.layoutFrame = frame
                    self.lock.lock()
                    self.arrayAttachments.append(replace)
                    self.lock.unlock()
                }
            }
        }
        
    }
    
    
}

extension YHAsyncMixedView:YHAsyncTextDrawerEventDelegate {
    public func contextViewForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> UIView {
        
        return self
    }
    
    public func activeRangesForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> [YHAsyncTextActiveRange]? {
        var arrayActiveRanges = [YHAsyncTextActiveRange]()
        if let arrayAtts = self.attributedItem?.arrayAttachments {
            for att in arrayAtts {
                var range = YHAsyncTextActiveRange.activeRangeInstance(NSRange.init(location: Int(att.position ?? 0), length: Int(att.length ?? 0)), intype: YHAsyncActiveRangeType.attach, intext: "")
                range.bindingData = att
                arrayActiveRanges.append(range)
            }
        }
        return arrayActiveRanges
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, didPress activeRange: YHAsyncTextActiveRange) {
        if activeRange.type == YHAsyncActiveRangeType.attach {
            if let att = activeRange.bindingData as? YHAsyncTextAttachment {
                att.handleEvent(self)
            }
        }
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, didHighlighted activeRange: YHAsyncTextActiveRange, frame rect: CGRect) {
        
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, shouldInteract activeRange: YHAsyncTextActiveRange) -> Bool {
        
        
        return true
    }
    
    
}

extension YHAsyncMixedView:YHAsyncTextLayoutDelegate {
    public func textLayout(_ textLayout: YHAsyncTextLayout?, truncatedLine: CTLine?, atIndex: UInt) -> CGFloat {
        return YHAsyncTextLayoutMaxSize.imumWidth
    }
}
