//
//  DemoOrderCellData.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class DemoOrderCellData: YHAsyncBaseCellData {
    var textDrawerDatas:[YHAsyncVisionObject] = [YHAsyncVisionObject]()
    
    override func getCurrentClass() -> String {
        return "DemoOrderListCell"
    }
    
}
