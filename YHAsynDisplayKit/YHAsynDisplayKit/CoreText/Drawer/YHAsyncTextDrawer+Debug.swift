//
//  YHAsyncTextLayout+Debug.swift
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

var textDrawerDebugModeEnabled:Bool = false

extension YHAsyncTextDrawer {
    
    class func debugModeSetEverythingNeedsDisplayForView(_ view:UIView) {
        view.setNeedsLayout()
        if view.responds(to: #selector(CALayerDelegate.display(_:))) {
            view.display(view.layer)
        }
        for subview in view.subviews {
            self.debugModeSetEverythingNeedsDisplayForView(subview)
        }
    }
    
    class func debugModeSetEverythingNeedsDisplay() {
        let windows = UIApplication.shared.windows
        for window in windows {
            self.debugModeSetEverythingNeedsDisplayForView(window)
        }
    }
    /**
    *  判断Debug开关是否打开
    *  @return YES or NO
    */
    
    class func debugModeEnabled() -> Bool {
        return textDrawerDebugModeEnabled
    }
    
    /**
    *  打开Debug开关
    */
    public class func enableDebugMode() {
        self.setDebugModeEnabled(true)
    }
    
    /**
    *  关闭Debug开关
    */
    public class func disableDebugMode() {
        self.setDebugModeEnabled(false)
    }
    
    /**
    *  设置Debug开关
    *
    *  @param enabled YES or NO
    */
    
    class func setDebugModeEnabled(_ enable:Bool) {
        textDrawerDebugModeEnabled = enable
        self.debugModeSetEverythingNeedsDisplay()
        CATransaction.flush()
    }
    
    /**
    *  框架内部使用，用来控制是否为每一个绘制元素添加调试底色
    *
    *  @param layoutFrame 排版结果
    *  @param ctx 上下文
    */
    
    func debugModeDrawLineFramesWithLayoutFrame(_ layoutFrame:YHAsyncTextLayoutFrame, _ context:CGContext) {
        context.saveGState()
        context.setAlpha(0.1)
        context.setFillColor(UIColor.green.cgColor)
        
        if let frame = self.getFrame() {
            context.fill(frame)
        }
        
        if let lines = layoutFrame.arrayLines {
            let lineWidth:CGFloat = 1 / UIScreen.main.scale
            for line in lines {
                guard var rect = line.lineRect else { continue }
                guard var drawOrigin = self.drawOrigin else { continue }
                guard let rect1 = self.convertRectFromLayout(rect, drawOrigin) else { continue}
                
                context.saveGState()
                context.setAlpha(0.3)
                context.setFillColor(UIColor.blue.cgColor)
                context.fill(rect1)
                
                var baselineRect = CGRect.init(x: 0, y: 0, width: rect1.size.width, height: lineWidth)
                if let baselineOrigin = line.baselineOrigin {
                    baselineRect.origin = self.convertPointFromLayout(baselineOrigin, drawOrigin)
                }
                
                context.setAlpha(0.6)
                context.setFillColor(UIColor.red.cgColor)
                context.fill(baselineRect)
                
                context.restoreGState()
            }
        }
        context.restoreGState()
    }
}

