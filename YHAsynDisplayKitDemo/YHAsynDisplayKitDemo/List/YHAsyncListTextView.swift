//
//  YHAsyncListTextView.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/26.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class YHAsyncListTextView: YHAsyncCanvasControl {
    fileprivate var _drawerDates:[YHAsyncVisionObject] = [YHAsyncVisionObject]()
    public var drawerDates:[YHAsyncVisionObject] {
        set {
            if _drawerDates == newValue {
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
        text.getTextLayout().delegate = self
        return text
    }()
    
    override init(frame: CGRect) {
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
    
    //MARK: - override
    override func drawInRect(_ rect: CGRect, context: CGContext?, asynchronously: Bool, userInfo: [String : Any]?) -> Bool {
        _ = super.drawInRect(rect, context: context, asynchronously: asynchronously, userInfo: userInfo)
        
        let initialDrawingCount = self.getDrawingCount()
        
        if self.drawerDates.count <= 0 {
            return true
        }
        
        for visiObject in self.drawerDates {
            self.textDrawer.setFrame(visiObject.visionFrame)
            self.textDrawer.getTextLayout().attributedString = visiObject.visionValue?.resultString
            self.textDrawer.drawInContext(context, visible: nil, attachments: true) { () -> Bool in
                return initialDrawingCount != self.getDrawingCount()
            }
        }
        
        return true
        
    }
    
    override func drawingDidFinishAsynchronously(_ asynchronously: Bool, success: Bool) {
        if !success {
            return
        }
        self.lock.lock()
        // 三个点： 锁重入、for循环遍历移除元素、多线程同步访问共享数据区
        for i in 0 ..< self.arrayAttachMents.count {
            if i >= 0 {
                let attachment = self.arrayAttachMents[i]
                if attachment.type == YHAsyncAttachmentType.StaticImage {
                    guard let asyncImage = attachment.contents as? YHAsyncImage else { continue }
                    // TODO: 图片下载流程
//                    asyncImage.loadImageWithUrl
                }
            }
        }
        
        
        
        self.lock.unlock()
    }
}

extension YHAsyncListTextView: YHAsyncTextDrawerDelegate {
    func textDrawer(_ textDrawer: YHAsyncTextDrawer, attachment replace: YHAsyncTextAttachment, rect frame: CGRect, _ context: CGContext) {
        
    }
    
    
}

extension YHAsyncListTextView: YHAsyncTextDrawerEventDelegate {
    func contextViewForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> UIView {
        
        return UIView()
    }
    
    func activeRangesForTextDrawer(_ textDrawer: YHAsyncTextDrawer) -> [YHAsyncTextActiveRange]? {
        return nil
    }
    
    func textDrawer(_ textDrawer: YHAsyncTextDrawer, didPress activeRange: YHAsyncTextActiveRange) {
        
    }
    
    func textDrawer(_ textDrawer: YHAsyncTextDrawer, didHighlighted activeRange: YHAsyncTextActiveRange, frame rect: CGRect) {
        
    }
    
    func textDrawer(_ textDrawer: YHAsyncTextDrawer, shouldInteract activeRange: YHAsyncTextActiveRange) -> Bool {
        
        return false
    }
    
    
}

extension YHAsyncListTextView :YHAsyncTextLayoutDelegate {
    func textLayout(_ textLayout: YHAsyncTextLayout?, truncatedLine: CTLine?, atIndex: UInt) -> CGFloat {
        return 0
    }
    
    
}
