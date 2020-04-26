//
//  YHAsyncDawnView.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/1.
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

typealias YHAsyncDrawCallback = (_ drawInBackground:Bool) -> Void

open class YHAsyncDawnView: UIView {

    // 绘制完成后，内容经过此时间的渐变显示出来，默认为 0.0
//    fileprivate var fadeDuration:TimeInterval = 0.0
    public func fadeDuration() -> TimeInterval {
        if let fadeDuration = self.drawingLayer?.fadeDuration {
            return fadeDuration
        }
        return 0.0
    }
    
    public func setFadeDuration(_ fro:TimeInterval) {
        self.drawingLayer?.fadeDuration = fro
    }
    
    // 绘制逻辑，定义同步绘制或异步，详细见枚举定义，默认为
//    public var drawingPolicy:YHAsyncDrawingPolicy = .asynchronouslyDrawWhenContentsChanged
    public func drawingPolicy() -> YHAsyncDrawingPolicy {
        if let drawingPolicy = self.drawingLayer?.drawingPolicy {
            return drawingPolicy
        }
        return .asynchronouslyDrawWhenContentsChanged
    }

    public func setDrawingPolicy(_ fro:YHAsyncDrawingPolicy) {
        self.drawingLayer?.drawingPolicy = fro
    }
    // 在drawingPolicy 为 WMGViewDrawingPolicyAsynchronouslyDrawWhenContentsChanged 时使用
    // 需要异步绘制时设置一次 YES，默认为NO
//    public var contentsChangedAfterLastAsyncDrawing:Bool = false
    public func getContentsChangedAfterLastAsyncDrawing() -> Bool {
        return self.drawingLayer?.contentsChangedAfterLastAsyncDrawing ?? false
    }
    
    public func setContentsChangedAfterLastAsyncDrawing(_ fro:Bool) {
        self.drawingLayer?.contentsChangedAfterLastAsyncDrawing = fro
    }
    
    // 下次AsyncDrawing完成前保留当前的contents
//    public var reserveContentsBeforeNextDrawingComplete:Bool = false
    public func reserveContentsBeforeNextDrawingComplete() -> Bool {
        return self.drawingLayer?.reserveContentsBeforeNextDrawingComplete ?? false
    }
    
    public func setReserveContentsBeforeNextDrawingComplete(_ fro:Bool) {
        self.drawingLayer?.reserveContentsBeforeNextDrawingComplete = fro
    }
    
    // 用于异步绘制的队列，为nil时将使用GCD的global queue进行绘制，默认为nil
    fileprivate var dispatchDrawQueue:DispatchQueue?
    
    public func setDispatchDrawQueue(_ fro:DispatchQueue?) {
        if let _ = self.dispatchDrawQueue {
            self.dispatchDrawQueue = nil
        }
        self.dispatchDrawQueue = fro
    }
    
    fileprivate func drawQueue() -> DispatchQueue? {
        if let dispatchDrawQueue = self.dispatchDrawQueue {
            return dispatchDrawQueue
        }
        
        return DispatchQueue(label: "YHAsyncDawnViewQueue", qos: self.dispatchPriority)
    }
    
    // 异步绘制时global queue的优先级，默认优先级为DEFAULT。在设置了drawQueue时此参数无效。
    public var dispatchPriority:DispatchQoS = DispatchQoS.default
    
    // 绘制次数
//    private(set) var drawingCount:NSInteger = 0
    public func getDrawingCount() -> NSInteger {
        if let drawingCount = self.drawingLayer?.drawingCount {
            return drawingCount
        }
        return 0
    }
    
    // 是否永远使用离屏渲染，默认YES。子类如果不希望离屏渲染必须重写此方法并 重写drawingPolicy为WMViewDrawingPolicySynchronouslyDraw
//    private(set) var alwaysUsesOffscreenRendering:Bool = true
    func alwaysUsesOffscreenRendering() -> Bool {
        return true
    }
    
    fileprivate weak var drawingLayer:YHAsyncDrawLayer?
    /**
     * 设置需要异步显示
     */
    public func setNeedsDisplayAsync() {
        self.setContentsChangedAfterLastAsyncDrawing(true)
        self.setNeedsDisplay()
    }
    
    /**
     * 如果可能，中断当前绘制工作
     */
    public func interruptDrawingWhenPossible() {
        self.drawingLayer?.increaseDrawingCount()
    }
    
//    #pragma mark - AsyncDraw Disable Control
    /**
     * 设置异步绘制全局开关
     *
     * @param disable YES or NO
     *
     */
    static var globalAsyncDrawDisabled:Bool = false
    
    public func setGlobalAsyncDrawingDisable(_ disable:Bool) {
        YHAsyncDawnView.globalAsyncDrawDisabled = disable
    }
    
    /**
     * 是否全局禁用了异步绘制
     *
     */
    class func globalAsyncDrawingDisabled() -> Bool {
        
        return YHAsyncDawnView.globalAsyncDrawDisabled
    }
    
    /**
     * 立即开始重绘流程，无需等到下一个runloop（异步绘制会在下个runloop开始）
     */
    public func redraw() {
        self.display(self.layer)
    }
    
//    #pragma mark - Methods for subclass overriding
    
    /**
     * 子类可以重写，并在此方法中进行绘制，请勿直接调用此方法
     *
     * @param rect 进行绘制的区域，目前只可能是 self.bounds
     * @param context 绘制到的context，目前在调用时此context都会在系统context堆栈栈顶
     * @param asynchronously 当前是否是异步绘制
     *
     * @return 绘制是否已执行完成。若为 NO，绘制的内容不会被显示
     *
     */
    open func drawInRect(_ rect:CGRect,context:CGContext?,asynchronously:Bool) -> Bool {
        return true
    }
    
    /**
     * 子类可以重写，并在此方法中进行绘制，请勿直接调用此方法
     *
     * @param rect 进行绘制的区域，目前只可能是 self.bounds
     * @param context 绘制到的context，目前在调用时此context都会在系统context堆栈栈顶
     * @param asynchronously 当前是否是异步绘制
     * @param userInfo 由currentDrawingUserInfo传入的字典，供绘制传参使用
     *
     * @return 绘制是否已执行完成。若为 NO，绘制的内容不会被显示
     */
    
    open func drawInRect(_ rect:CGRect,context:CGContext?,asynchronously:Bool,userInfo:[String:Any]?) -> Bool {
        
        return self.drawInRect(rect, context: context, asynchronously: asynchronously)
    }
    
    
    /**
     * 子类可以重写，是绘制即将开始前的回调，请勿直接调用此方法
     *
     * @param asynchronously 当前是否是异步绘制
     */
    
    open func drawingWillStartAsynchronously(_ asynchronously:Bool) {
        
    }
    
    /**
     * 子类可以重写，是绘制完成后的回调，请勿直接调用此方法
     *
     * @param asynchronously 当前是否是异步绘制
     * @param success 绘制是否成功
     *
     * @discussion 如果在绘制过程中进行一次重绘，会导致首次绘制不成功，第二次绘制成功。
     */
    
    open func drawingDidFinishAsynchronously(_ asynchronously:Bool, success:Bool) {
        
    }
    
    /**
     * 子类可以重写，用于在主线程生成并传入绘制所需参数
     *
     * @discussion 有时在异步线程配置参数可能导致crash，例如在异步线程访问ivar。可以通过此方法将参数放入字典并传入绘制方法。此方法会在displayLayer:的当前线程调用，一般为主线程。
     */
    
    open func currentDrawingUserInfo() -> [String:Any] {
        return [String : Any]()
    }
//    #pragma mark end - Methods for subclass overriding
    
    fileprivate func displayLayer(_ layer:YHAsyncDrawLayer,
                                  rectToDraw:CGRect,
                                  startCallback:YHAsyncDrawCallback?,
                                  finishCallback:YHAsyncDrawCallback?,
                                  interruptCallback:YHAsyncDrawCallback?) {
        let drawInBackground = layer.isAsyncDrawsCurrentContent() && !YHAsyncDawnView.globalAsyncDrawDisabled
        layer.increaseDrawingCount()
        let targetDrawingCount = layer.drawingCount
        let drawingUserInfo = self.currentDrawingUserInfo()
        
        let drawBlock = { [weak self] in
            let failedBlock = {
                if let interruptCallback = interruptCallback {
                    interruptCallback(drawInBackground)
                }
            }
            
            if layer.drawingCount != targetDrawingCount {
                failedBlock()
                return
            }
            
            let contextSize = layer.bounds.size
            let contextSizeValid = contextSize.width >= 1 && contextSize.height >= 1
            var context:CGContext? = nil
            var drawingFinished:Bool = true
            
            if contextSizeValid {
                UIGraphicsBeginImageContextWithOptions(contextSize, layer.isOpaque, layer.contentsScale)
                context = UIGraphicsGetCurrentContext()
                
                if (context == nil ) {
                    print("may be memory warning");
                }
                
                context?.saveGState()
                
                if rectToDraw.origin.x != 0 || rectToDraw.origin.y != 0 {
                    context?.translateBy(x: rectToDraw.origin.x, y: -rectToDraw.origin.y)
                }
                
                if layer.drawingCount != targetDrawingCount {
                    drawingFinished = false
                } else {
                    drawingFinished = self?.drawInRect(rectToDraw, context: context, asynchronously: drawingFinished, userInfo: drawingUserInfo) ?? false
                }
                
                context?.restoreGState()
            }
            // 所有耗时的操作都已完成，但仅在绘制过程中未发生重绘时，将结果显示出来
            
            if drawingFinished && layer.drawingCount == targetDrawingCount {
                let CGImage:CGImage? = context?.makeImage()
                if let cgImage = CGImage {
                    let image = UIImage.init(cgImage: cgImage)
                    
                    let finishBlock = {
                        // 由于block可能在下一runloop执行，再进行一次检查
                        if targetDrawingCount != layer.drawingCount {
                            failedBlock()
                            return
                        }
                        layer.contents = image.cgImage
                        
                        layer.contentsChangedAfterLastAsyncDrawing = false
                        layer.reserveContentsBeforeNextDrawingComplete = false
                        
                        if let finishedCallback = finishCallback {
                            finishedCallback(drawInBackground)
                        }
                        // 如果当前是异步绘制，且设置了有效fadeDuration，则执行动画
                        if drawInBackground && layer.fadeDuration > 0.0001 {
                            layer.opacity = 0.0
                            
                            UIView.animate(withDuration: layer.fadeDuration, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                                layer.opacity = 1.0
                            })
                        }
                    }
                    
                    if drawInBackground {
                        DispatchQueue.main.async {
                            finishBlock()
                        }
                    } else {
                        finishBlock()
                    }
                    
                } else {
                    failedBlock()
                }
                
                UIGraphicsEndImageContext()
            }
        }
        
        if let startCallback = startCallback {
            startCallback(drawInBackground)
        }
        
        if drawInBackground {
            // 清空 layer 的显示
            if layer.reserveContentsBeforeNextDrawingComplete == false {
                layer.contents = nil
            }
            self.drawQueue()?.async {
                drawBlock()
            }
        } else {
            let mainblock = {
                autoreleasepool{
                    drawBlock()
                }
            }
            
            if Thread.isMainThread {
                mainblock()
            } else {
                DispatchQueue.main.async {
                    mainblock()
                }
            }
        }
    }
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        self.layer.contentsScale = UIScreen.main.scale
        // make overrides work
        self.setDrawingPolicy(self.drawingPolicy())
        self.setFadeDuration(self.fadeDuration())
        self.setContentsChangedAfterLastAsyncDrawing(self.getContentsChangedAfterLastAsyncDrawing())
        self.setReserveContentsBeforeNextDrawingComplete(self.reserveContentsBeforeNextDrawingComplete())
        
        if self.layer.isKind(of: YHAsyncDrawLayer.self) {
            self.drawingLayer = self.layer as? YHAsyncDrawLayer
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - - View Life Cycle
    deinit {
        if let _ = self.dispatchDrawQueue {
            self.dispatchDrawQueue = nil
        }
    }
    
    //MARK: - Override From UIView
    public override class var layerClass: AnyClass {
        return YHAsyncDrawLayer.self
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        // 没有 Window 说明View已经没有显示在界面上，此时应该终止绘制
        if self.window == nil{
            self.interruptDrawingWhenPossible()
        }
        
        if self.layer.contents == nil {
            self.setNeedsDisplay()
        }
    }
    
    override public func responds(to aSelector: Selector!) -> Bool {
        if self.alwaysUsesOffscreenRendering() == false {
            // 此方法在 -[super initWithFrame:frame] 时检查，因此必须通过重写保证此时的drawingPolicy已设置正确
            if aSelector == #selector(CALayerDelegate.display(_:)) {
                return self.drawingPolicy() != .synchronouslyDraw
            }
        }
        return super.responds(to: aSelector)
    }
    
    public override func draw(_ rect: CGRect) {
        self.drawingWillStartAsynchronously(false)
        let context = UIGraphicsGetCurrentContext()
        
        if let context = context {
            _ = self.drawInRect(self.bounds, context: context, asynchronously: false, userInfo: self.currentDrawingUserInfo())
            self.drawingDidFinishAsynchronously(false, success: true)
        } else {
            print("context is nil, may be memory warning")
        }
        
    }
    
    override public func setNeedsDisplay() {
        self.layer.setNeedsDisplay()
    }
    
    override public func setNeedsDisplay(_ rect: CGRect) {
        self.layer.setNeedsDisplay(rect)
    }
    
    override public func display(_ layer: CALayer) {
        if layer != self.layer { return }
        
        guard let layer = layer as? YHAsyncDrawLayer else {
            return
        }
        
        self.displayLayer(layer, rectToDraw: self.bounds,
                          startCallback: { [weak self] drawInBackground in
                            self?.drawingWillStartAsynchronously(drawInBackground)
            },
                          finishCallback: { [weak self] drawInBackground in
                            self?.drawingDidFinishAsynchronously(drawInBackground, success: true)
            },
                          interruptCallback: { [weak self] drawInBackground in
                            self?.drawingDidFinishAsynchronously(drawInBackground, success: false)
        })
    }
}
