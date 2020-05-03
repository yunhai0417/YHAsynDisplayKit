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
    var orderContentView:YHAsyncListTextView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        let orderContentView = YHAsyncListTextView.init(frame: CGRect.init(x: 10, y: 5, width: 0, height: 0))
        orderContentView.cornerRadius = 5
        orderContentView.backgroundColor = UIColor.yellow
        self.contentView.addSubview(orderContentView)
        self.orderContentView = orderContentView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setupCellData(_ inCellData: DemoOrderCellData?) {
        super.setupCellData(inCellData)
        self.orderContentView?.frame = CGRect.init(x: 10, y: 5, width: cellData?.cellWidth ?? 0, height: cellData?.cellHeight ?? 0)
        if let textDrawerDatas = inCellData?.textDrawerDatas {
            self.orderContentView?.drawerDates = textDrawerDatas
        }
    }
    
}
