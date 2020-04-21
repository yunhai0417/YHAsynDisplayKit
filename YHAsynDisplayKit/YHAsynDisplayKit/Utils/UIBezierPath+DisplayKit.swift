//
//  UIBezierPath+DisplayKit.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/13.
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

extension UIBezierPath {
    /**
    * 该方法用来根据指定的矩形区域获取一个带圆角边框的路径
    * 一般情况下仅限于框架内部使用
    *
    * @param rect 矩形区域
    * @param radius 定义圆角的结构体，可以指定任意一个角的弧度
    * @param lineWidth 路径线条宽度
    *
    * @return 贝塞尔路径
    */
    
    class func bezierPathCreateWithRect(_ rect:CGRect, cornerRadius radius:YHAsyncCornerRadius, lineWidth width:CGFloat) -> UIBezierPath {
        if YHAsyncCornerRadiusIsPerfect(radius) {
            return UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize.init(width: radius.topLeft, height: radius.topLeft))
        }
        
        let lineCenter:CGFloat  = 0 //width / 2.0
        
        var path:UIBezierPath = UIBezierPath.init()
        path.move(to: CGPoint(x: radius.topLeft, y: lineCenter))
        
        path.addArc(withCenter: CGPoint(x: radius.topLeft, y: radius.topLeft), radius: radius.topLeft - lineCenter, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi, clockwise: false)
        
        path.addLine(to: CGPoint.init(x: lineCenter, y: rect.height - radius.bottomLeft))
        
        path.addArc(withCenter: CGPoint.init(x: radius.bottomLeft, y: rect.height - radius.bottomLeft), radius: radius.bottomLeft - lineCenter, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 0.5, clockwise: false)
        
        path.addLine(to: CGPoint.init(x: rect.width - radius.bottomRight, y: rect.height - lineCenter))
        
        path.addArc(withCenter: CGPoint(x: rect.width - radius.bottomRight, y: rect.height - radius.bottomRight), radius: radius.bottomRight - lineCenter, startAngle: CGFloat.pi * 0.5, endAngle: 0.0, clockwise: false)
        
        path.addLine(to: CGPoint.init(x: rect.width - lineCenter, y: radius.topRight))
        
        path.addArc(withCenter: CGPoint.init(x: rect.width - radius.topRight, y: radius.topRight), radius: radius.topRight - lineCenter, startAngle: 0.0, endAngle: CGFloat.pi * 1.5, clockwise: false)
        
        path.close()
        return path
    }
}
