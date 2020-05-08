//
//  YHAsyncMutableAttributeItem+Extension.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

extension YHAsyncMutableAttributedItem {
    public var snp: YHAsyncConstraintAttributeItemDSL {
        return YHAsyncConstraintAttributeItemDSL(attributeItem: self)
    }
    
    //依赖状态信息
    private static let associationItems = YHAsyncObjectAssociation<[YHAsyncConstraintItem]>.init(policy: .OBJC_ASSOCIATION_COPY_NONATOMIC)
    
    var relatedConstraintItems:[YHAsyncConstraintItem]? {
        get { return YHAsyncMutableAttributedItem.associationItems[self]  }
        set { YHAsyncMutableAttributedItem.associationItems[self] = newValue }
    }
    
    
    //返回一个YHAsyncMutableAttributedItem对应的视图元素
    func achieveVisionObject() -> YHAsyncVisionObject {
        let visionObject = YHAsyncVisionObject.init()
            visionObject.visionValue = self
        visionObject.visionFrame = self.relatedConstraintRect ?? CGRect.zero
        return visionObject
    }
}

