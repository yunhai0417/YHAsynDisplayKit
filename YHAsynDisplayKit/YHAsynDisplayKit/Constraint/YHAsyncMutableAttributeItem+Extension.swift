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
}

