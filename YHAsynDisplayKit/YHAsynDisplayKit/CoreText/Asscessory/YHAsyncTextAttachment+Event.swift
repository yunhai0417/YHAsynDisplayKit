//
//  YHAsyncTextAttachment+Event.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/5.
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

extension YHAsyncTextAttachment {
    /**
    *  给一个文本组件添加事件
    *
    * @param target 事件执行者
    * @param action 事件行为
    * @param controlEvents 事件类型
    *
    */
    func addTarget(_ target:AnyObject?, inAction action:Selector?, forControlEvents controlEvents:UIControl.Event) {
        self.target = target
        self.selector = action
        
        self.responseEvent = false
        if let target = target , let action = action {
            self.responseEvent = target.responds(to: action)
        }
    }
    
    /**
    *  处理事件，框架内部使用
    */
    
    func handleEvent(_ sender:AnyObject) {
        if let target = self.target , let action = self.selector {
            if target.responds(to: action) {
                target.perform(action, with: selector)
            }
        }
    }
}

