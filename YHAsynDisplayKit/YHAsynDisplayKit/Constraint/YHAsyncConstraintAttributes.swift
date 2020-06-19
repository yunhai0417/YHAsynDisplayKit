//
//  YHAsyncConstraintAttributes.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

class YHAsyncConstraintAttributes: OptionSet, ExpressibleByIntegerLiteral {
    // 整数字面量协议 ExpressibleByIntegerLiteral
    typealias IntegerLiteralType = UInt
    
    required internal init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    internal convenience init(_ rawValue: UInt) {
        self.init(rawValue: rawValue)
    }
    internal init(nilLiteral: ()) {
        self.rawValue = 0
    }
    required internal convenience init(integerLiteral rawValue: IntegerLiteralType) {
        self.init(rawValue: rawValue)
    }
    
    internal private(set) var rawValue: UInt
    internal static var allZeros: YHAsyncConstraintAttributes { return 0 }
    internal static func convertFromNilLiteral() -> YHAsyncConstraintAttributes { return 0 }
    internal var boolValue: Bool { return self.rawValue != 0 }
    
    internal func toRaw() -> UInt { return self.rawValue }
    internal class func fromRaw(_ raw: UInt) -> YHAsyncConstraintAttributes? {
        return YHAsyncConstraintAttributes.init(raw)
    }
    internal class func fromMask(_ raw: UInt) -> YHAsyncConstraintAttributes {
        return YHAsyncConstraintAttributes.init(raw)
    }
    
    // normal
    internal static var none: YHAsyncConstraintAttributes { return 0 }
    internal static var left: YHAsyncConstraintAttributes { return 1 }
    internal static var top: YHAsyncConstraintAttributes {  return 2 }
    internal static var right: YHAsyncConstraintAttributes { return 4 }
    internal static var bottom: YHAsyncConstraintAttributes { return 8 }
    internal static var leading: YHAsyncConstraintAttributes { return 16 }
    internal static var trailing: YHAsyncConstraintAttributes { return 32 }
    internal static var width: YHAsyncConstraintAttributes { return 64 }
    internal static var height: YHAsyncConstraintAttributes { return 128 }
    internal static var centerX: YHAsyncConstraintAttributes { return 256 }
    internal static var centerY: YHAsyncConstraintAttributes { return 512 }
    
    internal static var leftMargin: YHAsyncConstraintAttributes { return 4096 }
    internal static var rightMargin: YHAsyncConstraintAttributes { return 8192 }
    internal static var topMargin: YHAsyncConstraintAttributes { return 16384 }
    internal static var bottomMargin: YHAsyncConstraintAttributes { return 32768 }
    internal static var leadingMargin: YHAsyncConstraintAttributes { return 65536 }
    internal static var trailingMargin: YHAsyncConstraintAttributes { return 131072 }


    // aggregates
    internal static var edges: YHAsyncConstraintAttributes { return 15 }
    internal static var size: YHAsyncConstraintAttributes { return 192 }
    internal static var center: YHAsyncConstraintAttributes { return 768 }

    
}

internal func + (left:YHAsyncConstraintAttributes, right:YHAsyncConstraintAttributes) -> YHAsyncConstraintAttributes {
    return left.union(right)
}

internal func +=(left: inout YHAsyncConstraintAttributes, right: YHAsyncConstraintAttributes) {
    left.formUnion(right)
}

internal func -=(left: inout YHAsyncConstraintAttributes, right: YHAsyncConstraintAttributes) {
    left.subtract(right)
}

internal func ==(left: YHAsyncConstraintAttributes, right: YHAsyncConstraintAttributes) -> Bool {
    return left.rawValue == right.rawValue
}
