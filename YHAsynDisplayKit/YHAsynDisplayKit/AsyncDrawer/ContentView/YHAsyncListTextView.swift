//
//  YHAsyncListTextView.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/26.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

public class YHAsyncListTextView: YHAsyncCanvasControl {
    
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
    
    var lock:NSRecursiveLock = NSRecursiveLock.init()
    var arrayAttachMents = [YHAsyncTextAttachment]()
    var clickItem:YHAsyncMutableAttributedItem?
    
    lazy var textDrawer:YHAsyncTextDrawer = {
        let text = YHAsyncTextDrawer()
        text.delegate = self
        text.eventDelegate = self
        text.textLayout.delegate = self
        return text
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewFrame(_ inFrame:CGRect) {
        if !inFrame.equalTo(self.frame) {
            self.frame = inFrame
        }
    }
    
    //MARK: - 重写父类绘制的方法
    public override func drawInRect(_ rect: CGRect, context: CGContext?, asynchronously: Bool, userInfo: [String : Any]?) -> Bool {
        
        // 调用父类的绘制方法 绘制背景图
        _ = super.drawInRect(rect, context: context, asynchronously: asynchronously, userInfo: userInfo)
        
        let initialDrawingCount = self.drawingCount
        
        for visiObject in self.drawerDates {
            //待排版区域
            self.textDrawer.frame = visiObject.visionFrame
            //待排版内容
            self.textDrawer.textLayout.attributedString = visiObject.visionValue?.resultString
            //绘制内容到指定上下文
            self.textDrawer.drawInContext(context, visible: nil, attachments: true) { () -> Bool in
                return initialDrawingCount != self.drawingCount
            }
        }
        
        return true
        
    }
    
    override public func drawingDidFinishAsynchronously(_ asynchronously: Bool, success: Bool) {
        if !success {
            return
        }
        self.lock.lock()
        // 三个点： 锁重入、for循环遍历移除元素、多线程同步访问共享数据区
        var i:Int = 0
        while i < self.arrayAttachMents.count {
            if i >= 0 && i < self.arrayAttachMents.count {
                let attachment = self.arrayAttachMents[i]
                if attachment.type == YHAsyncAttachmentType.StaticImage || attachment.type == YHAsyncAttachmentType.OnlyImage {
                    guard let asyncImage = attachment.contents as? YHAsyncImage else { continue }
                    // TODO: 图片下载流程
                    guard let downLoadUrl = asyncImage.downloadUrl else { continue }
                    asyncImage.loadImageWithUrl(downLoadUrl, inoptions: [], inprogress: nil) { [weak self] (image, error, cacheType, imageURL) in
                        self?.lock.lock()
                        if self?.arrayAttachMents.contains(attachment) ?? false {
                            self?.arrayAttachMents.remove(at: i)
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
    
    //MARK: - Event Handling
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            for (_,objc) in self.drawerDates.enumerated() {
                let visionFrame = objc.visionFrame
                if frame.contains(location) {
                    self.clickItem = objc.visionValue
                    self.textDrawer.frame = visionFrame
                    self.textDrawer.textLayout.attributedString = objc.visionValue?.resultString
                }
            }
        }
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
    
    override public func beginTrackingWithTouch(_ touch: UITouch, withEvent: UIEvent?) -> Bool {
        return false
    }
}

//MARK:- YHAsyncTextDrawerDelegate
extension YHAsyncListTextView: YHAsyncTextDrawerDelegate {
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, attachment replace: YHAsyncTextAttachment, rect frame: CGRect, _ context: CGContext) {
        if replace.type == YHAsyncAttachmentType.StaticImage || replace.type == YHAsyncAttachmentType.OnlyImage {
            if let content = replace.contents as? String {
                UIGraphicsPushContext(context)
                let image = UIImage(named: content)
                image?.draw(in: frame)
                UIGraphicsPopContext()
            }
            
            if let image = replace.contents as? UIImage {
                UIGraphicsPushContext(context)
                image.draw(in: frame)
                UIGraphicsPopContext()
            }
            
            if let content = replace.contents as? YHAsyncImage {
                var cachedImage:UIImage?
                if let downLoadUrl = content.downloadUrl {
                    cachedImage = content.queryCacheImageWithUrl(downLoadUrl)
                }
                
                if let image = content.image {
                    UIGraphicsPushContext(context)
                    image.draw(in: frame)
                    UIGraphicsPopContext()
                } else if let image = cachedImage {
                    let image1 = cachedImage?.yh_blurImageWithBlurPercent(0.5)
                    content.image = image1
                    UIGraphicsPushContext(context)
                    image.draw(in: frame)
//                    image1?.draw(in: CGRect.init(x: 50, y: 50, width: 100, height: 100))
                    content.downloadUrl = nil
                    UIGraphicsPopContext()
                } else {
                    if let placeholderName = content.placeholderName {
                        UIGraphicsPushContext(context)
                        let image = UIImage(named: placeholderName)
                        image?.draw(in: frame)
                        UIGraphicsPopContext()
                    }
                }
                
                if let _ = content.downloadUrl {
                    replace.layoutFrame = frame
                    self.lock.lock()
                    self.arrayAttachMents.append(replace)
                    self.lock.unlock()
                }
            }
        }
    }
    
    
    
}


// MARK: - YHAsyncTextDrawerEventDelegate
extension YHAsyncListTextView: YHAsyncTextDrawerEventDelegate {
    public func contextViewForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> UIView {
        
        return self
    }
    
    public func activeRangesForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> [YHAsyncTextActiveRange]? {
        var arrayActiveRanges = [YHAsyncTextActiveRange]()
        if let arrayAttachments = self.clickItem?.arrayAttachments {
            for attachment in arrayAttachments {
                let range = YHAsyncTextActiveRange.activeRangeInstance(NSRange.init(location: Int(attachment.position ?? 0), length: Int(attachment.length ?? 0)), intype: YHAsyncActiveRangeType.attach, intext: "")
                range.bindingData = attachment
                arrayActiveRanges.append(range)
            }
        }
        
        return arrayActiveRanges
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, didPress activeRange: YHAsyncTextActiveRange) {
        if activeRange.type == YHAsyncActiveRangeType.attach {
            if let attachment = activeRange.bindingData as? YHAsyncTextAttachment{
                attachment.handleEvent(attachment.userInfo )
            }
        }
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, didHighlighted activeRange: YHAsyncTextActiveRange, frame rect: CGRect) {
        
    }
    
    public func textDrawer(_ textDrawer: YHAsyncTextDrawer, shouldInteract activeRange: YHAsyncTextActiveRange) -> Bool {
        
        return true
    }
    
    
}


//MARK: - YHAsyncTextLayoutDelegate
extension YHAsyncListTextView :YHAsyncTextLayoutDelegate {
    public func textLayout(_ textLayout: YHAsyncTextLayout?, truncatedLine: CTLine?, atIndex: UInt) -> CGFloat {
        return YHAsyncTextLayoutMaxSize.imumWidth
    }
    
    
}
