//
//  YHAsyncConstraintMakerExtendable.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public class YHAsyncConstraintMakerExtendable: YHAsyncConstraintMakerFinalizable {
    public var left:YHAsyncConstraintMakerExtendable {
        return self
    }
    
    
    var attributes:YHAsyncConstraintItem?
    
    init(_ inAttributes:YHAsyncConstraintItem) {
        self.attributes = inAttributes
    }
    
    @discardableResult
    public func relatedTo(_ other:YHAsyncConstraintRelatableTarget, file inFile:String, line inline:UInt) -> YHAsyncConstraintMakerEditable {
        let editable = YHAsyncConstraintMakerEditable()
        
        if let other = other as? UIView {
            editable.related = YHAsyncConstraintItem.init(target: other, attributes: YHAsyncConstraintAttributes.none)
        } else if let other = other as? YHAsyncMutableAttributedItem {
            editable.related = YHAsyncConstraintItem.init(target: other, attributes: YHAsyncConstraintAttributes.none)
        } else if let other = other as? YHAsyncConstraintRelatableTarget {
            editable.amount = other.constraintRelatableTargetValueFor(other)
        }
        
        editable.sourceLocation = (inFile,inline)
        self.attributes?.editable = editable
        return editable
    }
    
    @discardableResult
    public func equalTo(_ other:YHAsyncConstraintRelatableTarget, file inFile:String = #file, line inline:UInt = #line) -> YHAsyncConstraintMakerEditable{
        return self.relatedTo(other, file: inFile, line: inline)
    }
}

public class YHAsyncConstraintMakerEditable: YHAsyncConstraintMakerFinalizable {
    
    @discardableResult
    public func offset(_ amount:CGFloat) -> YHAsyncConstraintMakerEditable {
        self.amount = amount
        return self
    }
}

public class YHAsyncConstraintMakerFinalizable {
    var amount:CGFloat = 0
    var related:YHAsyncConstraintItem?
    var sourceLocation: (String, UInt)?
}
