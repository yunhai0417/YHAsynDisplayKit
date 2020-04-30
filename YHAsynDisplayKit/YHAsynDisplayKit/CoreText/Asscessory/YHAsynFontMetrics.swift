//
//  YHAsynFontMetrics.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/3/29.
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

import Foundation
import UIKit
import CoreText
import CoreGraphics

let YHAsyncFontMetricsZero:YHAsyncFontMetrics = YHAsyncFontMetrics(ascent: 0, descent: 0, leading: 0)
let YHAsyncFontMetricsNull:YHAsyncFontMetrics = YHAsyncFontMetrics(ascent: CGFloat(NSNotFound), descent: CGFloat(NSNotFound), leading: CGFloat(NSNotFound))

//字体缓存
var YHAsyncCachedFontMetricsList = [YHAsyncFontMetrics]()

//MARK: -YHAsyncFontMetrics static func

public func YHAsyncFontMetricsCreateMake(_ inascent:CGFloat, indescent descent:CGFloat, inleading leading:CGFloat) -> YHAsyncFontMetrics {
    var metrics = YHAsyncFontMetrics.init()
    metrics.ascent = inascent
    metrics.descent = descent
    metrics.leading = leading
    return metrics
}

public func YHAsyncFontMetricsCreateMake(_ uifont:UIFont?) -> YHAsyncFontMetrics {
    var metrics = YHAsyncFontMetricsZero
    
    if let tfont = uifont  {
        metrics.ascent = abs(tfont.ascender)
        metrics.descent = abs(tfont.descender)
        metrics.leading = abs(tfont.lineHeight) - metrics.ascent - metrics.descent
    }
    
    return metrics
}

public func YHAsyncFontMetricsCreateMake(_ ctfont:CTFont) -> YHAsyncFontMetrics {
    var metrics = YHAsyncFontMetrics.init()
    metrics.ascent = abs(CTFontGetAscent(ctfont))
    metrics.descent = abs(CTFontGetDescent(ctfont))
    metrics.leading = abs(CTFontGetLeading(ctfont))
    return metrics
}

public func YHAsyncFontMetricsCreateMakeWithLineHeight(_ metrics:YHAsyncFontMetrics, targetLineHeight:CGFloat) -> YHAsyncFontMetrics {
    
    var newMetrics = YHAsyncFontMetrics.init()
    newMetrics.ascent = targetLineHeight - metrics.descent - metrics.leading
    newMetrics.descent = metrics.descent
    newMetrics.leading = metrics.leading
    
    return newMetrics
}

// 计算字体高度
public func YHAsyncFontMetricsGetLineHeight(_ metrics:YHAsyncFontMetrics) -> CGFloat {
    return CGFloat(ceilf(Float(metrics.ascent + metrics.descent + metrics.leading)))
}

public func YHAsyncFontMetricsEqual(_ metricsLeft:YHAsyncFontMetrics?, inMetricsRight metricsRight:YHAsyncFontMetrics?) -> Bool {
    guard let metrics1 = metricsLeft else {
        return false
    }
    
    guard let metrics2 = metricsRight else {
        return false
    }
    return metrics1.ascent == metrics2.ascent
        && metrics1.descent == metrics2.descent
        && metrics1.leading == metrics2.leading
}

public func YHAsyncFontDefaultCreateMake(_ pointSize:CGFloat) -> YHAsyncFontMetrics {
    if pointSize < 8 || pointSize > 20 {
        let font:UIFont = UIFont.systemFont(ofSize: pointSize)
        return YHAsyncFontMetricsCreateMake(font)
    }
    
    _ = YHAsyncCachedFontMetrics.sharedInstance
    
    return YHAsyncCachedFontMetricsList[Int(pointSize) - 8]
}


public struct YHAsyncFontMetrics {
    var ascent: CGFloat = 0         //上部高度
    var descent: CGFloat = 0        //中部高度
    var leading: CGFloat = 0        //下部高度

    
}

class YHAsyncCachedFontMetrics: NSObject {
    class var sharedInstance : YHAsyncCachedFontMetrics {
        struct Static {
            static let instance : YHAsyncCachedFontMetrics = YHAsyncCachedFontMetrics()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        self.reloadCachedFontMetrics()
    }
    
    func reloadCachedFontMetrics() {
        autoreleasepool {
            for index in 0 ..< 13 {
                let pointSize:CGFloat = CGFloat(index + 8)
                let font:UIFont = UIFont.systemFont(ofSize: pointSize)
                YHAsyncCachedFontMetricsList[index] = YHAsyncFontMetricsCreateMake(font)
            }
        }
    }
}



