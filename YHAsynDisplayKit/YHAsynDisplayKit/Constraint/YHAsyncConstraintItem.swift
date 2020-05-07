//
//  YHAsyncConstraintItem.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public final class YHAsyncConstraintItem {
    weak var target: AnyObject?                  //当前对象
    var attributes: YHAsyncConstraintAttributes?                    //关联类型
    var relateItem: YHAsyncConstraintItem?                          //关联对象
    var amount: CGFloat = 0                                         //关联数据
    var relateAttributes:YHAsyncConstraintAttributes?               //关联约束
    
    
    init(inTarget: AnyObject?, inAttributes: YHAsyncConstraintAttributes) {
        self.target = inTarget
        self.attributes = inAttributes
    }
    
    init(inRelateTarget: AnyObject?, inAttributes:YHAsyncConstraintAttributes) {
        self.target = inRelateTarget
        self.relateAttributes = inAttributes
    }
    
    @discardableResult
    public func relatedTo(_ other:YHAsyncConstraintRelatableTarget, file inFile:String, line inline:UInt) -> YHAsyncConstraintItem {
        if let other = other as? YHAsyncConstraintItem {
            self.relateItem = other
        } else if let other = other as? UIView {
            self.relateItem = YHAsyncConstraintItem(inTarget: other, inAttributes: YHAsyncConstraintAttributes.none)
        } else if let other = other as? YHAsyncMutableAttributedItem {
            self.relateItem = YHAsyncConstraintItem(inTarget: other, inAttributes: YHAsyncConstraintAttributes.none)
        } else if let other = other as? YHAsyncConstraintRelatableTarget {
            self.constraintRelatableTargetValueFor(other)
        } else {
            fatalError("Invalid Item =(\(inFile),\(inline)) ")
        }

        return self
    }
    
    @discardableResult
    public func equalTo(_ other:YHAsyncConstraintRelatableTarget, file inFile:String = #file, line inline:UInt = #line) -> YHAsyncConstraintItem{
        return self.relatedTo(other, file: inFile, line: inline)
    }
    
    @discardableResult
    public func offset(_ amount:CGFloat) -> YHAsyncConstraintItem {
        self.amount = amount
        return self
    }
    
    func constraintRelatableTargetValueFor(_ item:YHAsyncConstraintRelatableTarget) {
        if let value = item as? CGFloat {
            self.amount = value
        }
        
        if let value = item as? Float {
            self.amount = CGFloat(value)
        }
        
        if let value = item as? Double {
            self.amount = CGFloat(value)
        }
        
        if let value = item as? Int {
            self.amount = CGFloat(value)
        }
        
        if let value = item as? UInt {
            self.amount = CGFloat(value)
        }
    }
}
