//
//  YHAsyncConstraintRelatableTarget.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public protocol YHAsyncConstraintRelatableTarget {
}

extension Int: YHAsyncConstraintRelatableTarget {
}

extension UInt: YHAsyncConstraintRelatableTarget {
}

extension Float: YHAsyncConstraintRelatableTarget {
}

extension Double: YHAsyncConstraintRelatableTarget {
}

extension CGFloat: YHAsyncConstraintRelatableTarget {
}

extension CGSize: YHAsyncConstraintRelatableTarget {
}

extension CGPoint: YHAsyncConstraintRelatableTarget {
}

extension UIView: YHAsyncConstraintRelatableTarget {
}

extension YHAsyncMutableAttributedItem: YHAsyncConstraintRelatableTarget {
}

extension YHAsyncConstraintRelatableTarget {
    func constraintRelatableTargetValueFor(_ item:YHAsyncConstraintRelatableTarget) -> CGFloat{
        if let value = self as? CGFloat {
            return value
        }
        
        if let value = self as? Float {
            return CGFloat(value)
        }
        
        if let value = self as? Double {
            return CGFloat(value)
        }
        
        if let value = self as? Int {
            return CGFloat(value)
        }
        
        if let value = self as? UInt {
            return CGFloat(value)
        }
        return 0
    }
}
