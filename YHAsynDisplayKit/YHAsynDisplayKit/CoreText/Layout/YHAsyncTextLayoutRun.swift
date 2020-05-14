//
//  YHAsyncTextLayoutRun.swift
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

import Foundation
import CoreText

//MARK: CTRun 功能封装
public class YHAsyncTextLayoutRun: NSObject {

    /**
     * 根据文本组件创建一个CTRunDelegateRef，即CoreText可以识别的一个占位
     *
     * @param att WMGAttachment
     *
     */
    
    class func textLayoutRunWithAttachment(_ att:YHAsyncTextAttachment) -> CTRunDelegate? {
        let count = 3
        let stride = MemoryLayout<CGFloat>.stride
        let aligment = MemoryLayout<CGFloat>.alignment
        let byteCount = stride * count
        
        var pointAtt = UnsafeMutableRawPointer.allocate(byteCount: byteCount , alignment: aligment)
        
        if let ascent = att.baselineFontMetrics?.ascent, ascent > 0 {
            pointAtt.storeBytes(of: ascent, as: CGFloat.self)
        } else {
            pointAtt.storeBytes(of: 20, as: CGFloat.self)
        }
        
        if let descent = att.baselineFontMetrics?.descent, descent > 0  {
            pointAtt.advanced(by: stride).storeBytes(of: descent, as: CGFloat.self)
        } else {
            pointAtt.advanced(by: stride).storeBytes(of: 5, as: CGFloat.self)
        }
        
        if let width = att.placeholderSize()?.width, width > 0 {
            pointAtt.advanced(by: stride).advanced(by: stride).storeBytes(of: width, as: CGFloat.self)
        } else {
            pointAtt.advanced(by: stride).advanced(by: stride).storeBytes(of: 25, as: CGFloat.self)
        }
        
        var callbacks = CTRunDelegateCallbacks.init(version: kCTRunDelegateCurrentVersion,
                                                    dealloc: {  (refCon) in /* do noting */ },
                        getAscent: { (refCon) -> CGFloat in
                            let result = refCon.load(as: CGFloat.self)
                            return result
                        },
                        getDescent: { (refCon) -> CGFloat in
                            let stride1 = MemoryLayout<CGFloat>.stride
                            let result = refCon.advanced(by: stride1).load(as: CGFloat.self)
                            return result
                        },
                        getWidth: { (refCon) -> CGFloat in
                            let stride1 = MemoryLayout<CGFloat>.stride
                            let result = refCon.advanced(by: stride1).advanced(by: stride1).load(as: CGFloat.self)
                            return result
                        })
        
        return CTRunDelegateCreate(&callbacks, pointAtt)
    }
}

