//
//  DemoOrderListCell.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class DemoOrderListCell: YHAsyncBaseTBCell {
//    var orderContentView:
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
