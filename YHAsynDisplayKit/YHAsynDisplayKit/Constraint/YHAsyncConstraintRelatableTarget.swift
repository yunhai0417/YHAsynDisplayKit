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

extension YHAsyncConstraintItem: YHAsyncConstraintRelatableTarget {
}

