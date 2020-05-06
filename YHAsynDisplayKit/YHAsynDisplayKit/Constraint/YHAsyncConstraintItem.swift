//
//  YHAsyncConstraintItem.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/6.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public final class YHAsyncConstraintItem {
    weak var target: AnyObject?
    var attributes: YHAsyncConstraintAttributes?
    var editable:YHAsyncConstraintMakerEditable?
    
    init(target: AnyObject?, attributes: YHAsyncConstraintAttributes) {
        self.target = target
        self.attributes = attributes
    }
}
