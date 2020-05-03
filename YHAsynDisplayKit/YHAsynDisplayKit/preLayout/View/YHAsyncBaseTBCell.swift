//
//  YHAsyncBaseTBCell.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/22.
//  Copyright © 2020 YH. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Foundation
import CoreGraphics


open class YHAsyncBaseTBCell: UITableViewCell {
    // 视图背景视图
    public lazy var bgView:UIView = {
        let bgView = UIView.init(frame: CGRect.zero)
        bgView.backgroundColor = UIColor.white
        return bgView
    }()
    
    // cell视图分割线定义
    public var separatorLine:UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = UIColor(red:((CGFloat)((0xe4e4e4 & 0xFF0000) >> 16)) / 255.0,green: ((CGFloat)((0xe4e4e4 & 0xFF00) >> 8)) / 255.0,blue: ((CGFloat)(0xe4e4e4 & 0xFF)) / 255.0,alpha: 1.0)
        return lineView
    }()
    
    // 视图点击等的事件代理回调
    
    
    // 视图展示的排版数据
    public var cellData:YHAsyncBaseCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.bgView)
        self.contentView.addSubview(self.separatorLine)
        
        self.contentView.backgroundColor = UIColor.clear
        self.accessibilityIdentifier = YHAsyncBaseTBCell.self.reuseIdentifier()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    /**
    * 为视图设置排版数据,添加分割线
    * @param cellData  视图排版数据
    */
    open func setupCellData(_ inCellData:YHAsyncBaseCellData?) {
        if let newCellData = inCellData {
            self.bgView.frame = CGRect.init(x: 0, y: 0, width: newCellData.cellWidth, height: newCellData.cellHeight)
            self.separatorLine.isHidden = newCellData.separatorStyle == .none
            self.contentView.bringSubviewToFront(self.separatorLine)
            
            let height:CGFloat = 1 / UIScreen.main.scale
            
            if newCellData.separatorStyle == .leftPadding {
                self.separatorLine.frame = CGRect.init(x: 15, y: newCellData.cellHeight -  height, width: newCellData.cellWidth - 15, height: height)
            } else if newCellData.separatorStyle == .rightPadding {
                self.separatorLine.frame = CGRect.init(x: 0, y: newCellData.cellHeight -  height, width: newCellData.cellWidth - 15, height: height)
            } else if newCellData.separatorStyle == .nonePadding {
                self.separatorLine.frame = CGRect.init(x: 0, y: newCellData.cellHeight -  height, width: newCellData.cellWidth , height: height)
            }
            
        } else {
            self.bgView.frame = CGRect.zero
            self.separatorLine.isHidden = true
        }
        self.cellData = inCellData
    }
}
