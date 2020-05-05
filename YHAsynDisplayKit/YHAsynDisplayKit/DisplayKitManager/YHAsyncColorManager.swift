//
//  YHAsyncColorManager.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/4.
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

/*
 *  简单的颜色管理，外部可不用
 */

public class YHAsyncColorManager: NSObject {
    //MARK: YHAsyncColorManager Color颜色管理
    fileprivate static var instanced:YHAsyncColorManager{
        get{
            struct YHAsyncColorManagerStruct{
                static var ins:YHAsyncColorManager = YHAsyncColorManager();
            }
            
            return YHAsyncColorManagerStruct.ins
        }
    }
    
    //创建管理类 非单例
    public class func sharedInstance() -> YHAsyncColorManager {
        return self.instanced
    }
    
    //获取颜色
    public class func achieveColor(_ color:NSInteger) -> UIColor {
        return UIColor(red:((CGFloat)((color & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((color & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(color & 0xFF)) / 255.0, alpha: 1.0)
    }
}
