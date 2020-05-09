//
//  YHAsyncTextLayout+Coordinate.swift
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

extension YHAsyncTextDrawer {
    /**
    *  将坐标点从文字布局中转换到 TextDrawer 的绘制区域中
    *
    *  @param point 需要转换的坐标点
    *
    *  @return 转换过的坐标点
    */
    func convertPointFromLayout(_ point:CGPoint, _ offsetPoint:CGPoint ) -> CGPoint {
        var newPoint = point
        newPoint.x += offsetPoint.x
        newPoint.y += offsetPoint.y
        return newPoint
    }
    
    /**
    *  将坐标点从 TextDrawer 的绘制区域转换到文字布局中
    *
    *  @param point 需要转换的坐标点
    *
    *  @return 转换过的坐标点
    */
    func convertPointToLayout(_ point:CGPoint, _ offsetPoint:CGPoint ) -> CGPoint {
        var newPoint = point
        newPoint.x -= offsetPoint.x
        newPoint.y -= offsetPoint.y
        return newPoint
    }
    
    /**
    *  将一个 rect 从文字布局中转换到 TextDrawer 的绘制区域中
    *  @param rect 需要转换的 rect
    *  @return 转换后的 rect
    */
    
    func convertRectFromLayout(_ rect:CGRect?, _ offsetPoint:CGPoint) -> CGRect? {
        guard let rect = rect else {
            return nil
        }
        
        if rect.isNull {
            return rect
        }
        
        var newRect = rect
        newRect.origin = self.convertPointFromLayout(rect.origin, offsetPoint)
        return newRect
    }
    
    /**
    *  将一个 rect 从 TextDrawer 的绘制区域转换到文字布局中
    *
    *  @param rect 需要转换的 rect
    *
    *  @return 转换后的 rect
    */
    func convertRectToLayout(_ rect:CGRect, _ offsetPoint:CGPoint) -> CGRect {
        if rect.isNull {
            return rect
        }
        
        var newRect = rect
        newRect.origin = self.convertPointToLayout(rect.origin, offsetPoint)
        return newRect
    }
}

