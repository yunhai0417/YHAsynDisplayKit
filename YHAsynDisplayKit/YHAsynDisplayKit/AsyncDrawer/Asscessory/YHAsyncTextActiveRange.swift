//
//  YHAsynTextActiveRange.swift
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

import Foundation

enum YHAsyncActiveRangeType:NSInteger {
    case unKnow = 0
    case uRL    = 1
    case email  = 2
    case phone  = 3
    case attach = 4
    case text   = 5
}

protocol YHAsyncActiveRange:NSObjectProtocol {
    var type: YHAsyncActiveRangeType? { get set }
    var range: NSRange? { get set }
    var text: String? { get set }
    // 涉及处理的相关数据
    var bindingData: NSObject? { get set }
}

public class YHAsyncTextActiveRange: NSObject, YHAsyncActiveRange {
    var type: YHAsyncActiveRangeType?
    
    var range: NSRange?
    
    var text: String?
    
    var bindingData: NSObject?
    
    /**
     * 创建一个激活区，框架内部使用
     *
     * @param range 激活区对应的range
     * @param type 激活区类型
     * @param text 如果是非WMGActiveRangeTypeAttachment类型的指定才有意义
     *
     * @return 激活区
     */
    class func activeRangeInstance(_ inrange:NSRange, intype:YHAsyncActiveRangeType, intext:String) -> YHAsyncTextActiveRange {
        let textRange = YHAsyncTextActiveRange.init()
        textRange.type  = intype
        textRange.range = inrange
        textRange.text  = intext
        return textRange
    }
}
