//
//  YHAsyncBaseCellData.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/22.
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

public enum YHAsyncCellSeparatorLineStyle: NSInteger {
    case none           = 0   //没有线
    case leftPadding    = 1   //左侧留有空白
    case rightPadding   = 2   //右侧留有空白
    case nonePadding    = 3   //双侧无空白
}

public class YHAsyncBaseCellData: NSObject {
    // cell宽度
    public var cellWidth:CGFloat = 0
        
    // cell高度
    public var cellHeight:CGFloat = 0
        
    // 视图分割线样式
    public var separatorStyle = YHAsyncCellSeparatorLineStyle.none
        
        
    // UI数据对应的业务数据
    public var metaData:YHAsyncClientDataProtocol?
        
        
    // 根据该属性值反射UI数据对应的视图Class，子类可以通过覆盖方式指定，默认取当前类同名对应的Cell
    // 例如: YHAsyncListCellData -> YHAsyncListCell
    public func getCurrentClass() -> String {
        let name = type(of: self)
        return "\(name)"
    //        return "YHAsyncBaseTBCell"
    }
}
