//
//  YHAsyncConstraintDSL.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public protocol YHAsyncConstraintDSL {
    var target:AnyObject? { get }
    
    func setLabel(_ value: String?)
    func label() -> String?
}

private var labelKey: UInt8 = 0

extension YHAsyncConstraintDSL {
    public func setLabel(_ value: String?) {
        objc_setAssociatedObject(self.target as Any, &labelKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    public func label() -> String? {
        return objc_getAssociatedObject(self.target as Any, &labelKey) as? String
    }
}


public protocol YHAsyncConstraintBasicAttributeDSL: YHAsyncConstraintDSL {
}

extension YHAsyncConstraintBasicAttributeDSL {
    //MARK: Basic
    public var left: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.left)
    }
    
    public var top: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.top)
    }
    
    public var right: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.right)
    }
    
    public var bottom: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.bottom)
    }
    
    public var leading: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.leading)
    }
    
    public var trailing: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.trailing)
    }
    
    public var width: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.width)
    }
    
    public var height: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.height)
    }
    
    public var centerX: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.centerX)
    }
    
    public var centerY: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.centerY)
    }
    
    public var size: YHAsyncConstraintItem {
        return YHAsyncConstraintItem(inRelateTarget: self.target, inAttributes: YHAsyncConstraintAttributes.size)
    }
    
}

public protocol YHAsyncConstraintAttributeDSL: YHAsyncConstraintBasicAttributeDSL {
}

extension YHAsyncConstraintAttributeDSL {
    //MARK: BaseLines
}

public struct YHAsyncConstraintAttributeItemDSL: YHAsyncConstraintAttributeDSL {
    
    weak var targetItem:YHAsyncMutableAttributedItem?
    
    init(attributeItem target:YHAsyncMutableAttributedItem) {
        self.targetItem = target
    }
    
    public var target: AnyObject? {
        return self.targetItem
    }
    
    //MARK: 添加约束
    public func makeConstraints(_ clouse: (_ make:YHAsyncConstraintMaker) -> Void) {
        YHAsyncConstraintMaker.makeConstraints(self.targetItem, clouse: clouse)
    }
}
