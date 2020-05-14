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

import UIKit

//MARK: 坐标转换
extension YHAsyncTextLayout {
    /**
     * 将UIKit坐标系统的点转换到CoreText坐标系统的点
     *
     * @param point UIKit坐标系统的点
     *
     * @return CoreText坐标系统的点
     */
    func yhAsyncCTPointFromUIPoint(_ point:CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.y = self.size.height - point.y
        return newPoint
    }
    /**
     * 将CoreText坐标系统的点转换到UIKit坐标系统的点
     *
     * @param point CoreText坐标系统的点
     *
     * @return UIKit坐标系统的点
     */
    func yhAsyncUIPointFromCTPoint(_ point:CGPoint?) -> CGPoint? {
        guard let point = point else { return nil }
        var newPoint = point
        newPoint.y = self.size.height - point.y;
        return newPoint
    }
    
    /**
     * 将UIKit坐标系统的rect转换到CoreText坐标系统的rect
     *
     * @param rect UIKit坐标系统的rect
     *
     * @return CoreText坐标系统的rect
     */
    func yhAsyncCTRectFromUIRect(_ rect:CGRect) -> CGRect {
        var newRect = rect
        newRect.origin = self.yhAsyncCTPointFromUIPoint(rect.origin);
        newRect.origin.y -= rect.size.height;
        return newRect
    }
    
    /**
     * 将CoreText坐标系统的rect转换到UIKit坐标系统的rect
     *
     * @param rect CoreText坐标系统的rect
     *
     * @return UIKit坐标系统的rect
     */
    func yhAsyncUIRectFromCTRect(_ fro:CGRect) -> CGRect {
        
        return CGRect.zero
    }
}

