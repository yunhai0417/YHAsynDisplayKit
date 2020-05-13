//
//  YHAsyncDrawLayer.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/3/30.
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
import QuartzCore

public enum YHAsyncDrawingPolicy: NSInteger {
    // 当 contentsChangedAfterLastAsyncDrawing 为 YES 时异步绘制
    case asynchronouslyDrawWhenContentsChanged = 1
    // 同步绘制
    case synchronouslyDraw                     = 2
    // 异步绘制
    case asynchronouslyDraw                    = 3
}

//MARK: YHAsyncDrawLayer绘制的目标Layer
public class YHAsyncDrawLayer: CALayer {
    // 绘制完成后，内容经过此时间的渐变显示出来，默认为 0.0
    var fadeDuration: TimeInterval = 0.0
    
    //: 绘制逻辑，定义同步绘制或异步，详细见枚举定义，默认为
    var drawingPolicy: YHAsyncDrawingPolicy = .asynchronouslyDrawWhenContentsChanged
    
    /*
     *  在drawingPolicy 为 ViewDrawingPolicyAsynchronouslyDrawWhenContentsChanged 时使用
     *  需要异步绘制时设置一次 YES，默认为NO
     */
    var contentsChangedAfterLastAsyncDrawing: Bool = false
    
    // 下次AsyncDrawing完成前保留当前的contents
    var reserveContentsBeforeNextDrawingComplete: Bool = false
    
    // 绘制次数
    var drawingCount:NSInteger = 0
    /**
     * 增加异步绘制次数
     */
    func increaseDrawingCount() {
        self.drawingCount = ( self.drawingCount + 1 ) % 10000
    }
    
    /**
     * 当前内容是否异步绘制
     */
    func isAsyncDrawsCurrentContent() -> Bool {
        switch self.drawingPolicy {
        case .asynchronouslyDrawWhenContentsChanged:
            return self.contentsChangedAfterLastAsyncDrawing
        case .asynchronouslyDraw:
            return true
        case .synchronouslyDraw:
            return false
        }
    }
    
    override public func setNeedsDisplay() {
        self.increaseDrawingCount()
        super.setNeedsDisplay()
    }
    
    override public func setNeedsDisplay(_ r: CGRect) {
        self.increaseDrawingCount()
        super.setNeedsDisplay(r)
    }
}
