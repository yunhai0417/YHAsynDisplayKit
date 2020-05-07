//
//  YHAsyncConstraintMaker.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/5.
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

//MARK: AttributeItem 视觉元素 约束组件
public class YHAsyncConstraintMaker: NSObject {
    
    public var left:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.left)
    }
    
    public var top:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.top)
    }
    
    public var bottom:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.bottom)
    }
    
    public var right:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.right)
    }
    
    public var height:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.height)
    }
    
    public var width:YHAsyncConstraintItem {
        return self.makeExtendableWithAttributes(.width)
    }
    
    var constraintItems = [YHAsyncConstraintItem]()
    //添加内容
    func makeExtendableWithAttributes(_ attributes:YHAsyncConstraintAttributes) -> YHAsyncConstraintItem {
        let item = YHAsyncConstraintItem(inTarget: self.target, inAttributes: attributes)
        self.constraintItems.append(item)
        return item
    }
    
    static func makeConstraints(_ item:YHAsyncMutableAttributedItem?, clouse:(_ make:YHAsyncConstraintMaker) -> Void) {
        guard let item = item else { return }
        let maker = YHAsyncConstraintMaker(item)
        clouse(maker)
        
        for constraintItem in maker.constraintItems {
            if let attributes = constraintItem.attributes?.rawValue {
                print("attributes = \(attributes)" )
            }
            print("constraintItem.amount = \(constraintItem.amount)")
            print("constraintItem.relateItem = \(constraintItem.relateItem)")
            
        }
        
        maker.target?.relatedConstraintItems = maker.constraintItems
    }
    
    weak var target:YHAsyncMutableAttributedItem?
    
    public init(_ item:YHAsyncMutableAttributedItem) {
        super.init()
        self.target = item
    }

}
