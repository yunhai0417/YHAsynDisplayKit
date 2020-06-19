//
//  YHAsyncAttributeManager.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/5/4.
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

/*
 *  YHAsyncAttributeManager
 *  承担管理工作，
 *  支持相对约束布局，
 *  区分图片为文本附件还是图片
 */

import UIKit
//MARK: YHAsyncMutableAttributedItem 管理类。T 最终绘制视图
public class YHAsyncAttributeManager<T:YHAsyncCanvasControl>: NSObject {

    //MARK: YHAsyncAttributeManager 创建管理
    fileprivate static var instanced:YHAsyncAttributeManager{
        get{
            return YHAsyncAttributeManager()
        }
    }
    
    //MARK: 创建管理类 非单例
    public class func sharedInstance() -> YHAsyncAttributeManager {
        return self.instanced
    }
    
    
    //MARK: 成员属性
    //文本视觉属性list
    //只有当前attributeItemList 视觉元素才能生效，元素之间的UI管理
    fileprivate lazy var attributeItemList: [YHAsyncMutableAttributedItem] = {
        let attributeItemList = [YHAsyncMutableAttributedItem]()
        return attributeItemList
    }()
    
    /*
     * 视觉元素最终绘制的目标视图
     * 1.默认frame -> cgrect.zero
     * 2.展示设置，优先按照父控件的size设置内容视觉元素的最终绘制，如果未指定宽度按照屏幕宽度绘制
     */
    lazy var canvasDrawerView:YHAsyncCanvasControl = {
        let mixView = YHAsyncListTextView.init(frame: CGRect.zero)
        return mixView
    }()
    
    public override init() {
        super.init()
    }
    
    //MARK: 成员方法-> 视觉元素
    //1.根据Text创建一个空内容 AttributedItem 用于后续承载数据
    //2.添加AttributeItem 到管理类中
    public func createAttributeItem() -> YHAsyncMutableAttributedItem {
        let item = YHAsyncMutableAttributedItem.init("")
        return item
    }
    
    //MARK: 添加AttributedItem到Manager中，如果不加入将使用frame做展示逻辑ß
    public func insertAttributeItem(_ newItem:YHAsyncMutableAttributedItem) {
        self.attributeItemList.append(newItem)
    }
    
    
    //MARK: 成员方法-> 绘制视图
    // default: YHAsyncMixedView
    public func achieveCurrentCanvasView() -> YHAsyncCanvasControl {
        return self.canvasDrawerView
    }
    
    public func updateCurrentCanvasView(_ newCanvas:T) {
        self.canvasDrawerView = newCanvas
    }
    
    //MARK: 绘制方法-> 绑定视觉元素到绘制视图中
    public func bindAttributeWithCanvasView() -> CGSize{
        self.computeAttributeItemListFrame()
        
        var drawerDates = [YHAsyncVisionObject]()
        
        for item in self.attributeItemDic.values {
            drawerDates.append(item.achieveVisionObject())
        }
        
        if let listView = self.canvasDrawerView as? YHAsyncListTextView {
            
            listView.drawerDates = drawerDates
            return CGSize.zero
        }
        
        if let mixedView = self.canvasDrawerView as? YHAsyncMixedView {
            mixedView.attributedItem = self.attributeItemList.first
        }
        return self.attributeItemList[0].resultString?.attributedSize() ?? CGSize.zero
    }
    
    fileprivate var attributeItemDic = [Int:YHAsyncMutableAttributedItem]()
    
    //MARK: 计算AttributeItem 相对约束
    fileprivate func computeAttributeItemListFrame() {
        for item in self.attributeItemList {
            let itemId = item.hashValue
            if let _ = attributeItemDic[itemId] {
                continue
            }
            self.computeAttributeItemFrame(item)
        }
    }
    
    /*
     *  AttributeContraints 转换到frame
     *  YHAsyncMutableAttributedItem 分为2部分
     *  YHAsyncConstraintItem :相对于 canvasView + width + height
     *                        :相对于YHAsyncConstraintItem的位置
     *  计算生成实际的frame
     */
    
    fileprivate func computeAttributeItemFrame(_ item:YHAsyncMutableAttributedItem) {
        guard var relatedConstraintItems = item.relatedConstraintItems else { return }
        var frame = CGRect.zero
        
        for constraintItem in relatedConstraintItems.sorted(by: { $0.attributes.rawValue > $1.attributes.rawValue })
        {
            if constraintItem.attributes == .width {
                var width = constraintItem.amount
                if let relateItem = constraintItem.relateItem {
                    if relateItem.attributes == .width || relateItem.attributes == .height {
                        width = relateItem.amount
                    }
                }
                frame.size.width = width
            }
            
            if constraintItem.attributes == .height {
                var height = constraintItem.amount
                if let relateItem = constraintItem.relateItem {
                    if relateItem.attributes == .width || relateItem.attributes == .height {
                        height = relateItem.amount
                    }
                }
                frame.size.height = height
            }
            
            if constraintItem.attributes == .top {
                var top:CGFloat = 0
                if let relateItem = constraintItem.relateItem {
                    if let view = relateItem.target as? YHAsyncCanvasControl {
                        top = relateItem.amount
                    }
                    
                    if let attributeItem = relateItem.target as? YHAsyncMutableAttributedItem {
                        
                        if let _ = self.attributeItemDic[attributeItem.hashValue] {
                        } else {
                            self.computeAttributeItemFrame(attributeItem)
                        }
                        
                        top = relateItem.amount
                        if relateItem.attributes == .top {
                            top = top + attributeItem.relatedConstraintRect.origin.y
                        }
                        
                        if relateItem.attributes == .bottom {
                            top = top + attributeItem.relatedConstraintRect.origin.y + attributeItem.relatedConstraintRect.size.height
                        }
                    }
                    
                    
                    frame.origin.y = top
                }
            }
            
            if constraintItem.attributes == .bottom {
                
                if let relateItem = constraintItem.relateItem {
                    var bottom:CGFloat = 0
                    if let view = relateItem.target as? YHAsyncCanvasControl {
                        bottom = relateItem.amount
                    }
                    
                    if let attributeItem = relateItem.target as? YHAsyncMutableAttributedItem {
                        
                        if let _ = self.attributeItemDic[attributeItem.hashValue] {
                        } else {
                            self.computeAttributeItemFrame(attributeItem)
                        }
                        
                        if relateItem.attributes == .top {
                            bottom = attributeItem.relatedConstraintRect.origin.y
                        }
                        
                        if relateItem.attributes == .bottom {
                            bottom = attributeItem.relatedConstraintRect.origin.y + attributeItem.relatedConstraintRect.size.height
                        }
                        
                        bottom = bottom + relateItem.amount
                    }
                    
                    let height = self.canvasDrawerView.frame.size.height
                    frame.origin.y = height - bottom - frame.size.height
                }
            }
            
            if constraintItem.attributes == .left {
                
                if let relateItem = constraintItem.relateItem {
                    var left:CGFloat = 0
                    if let view = relateItem.target as? YHAsyncCanvasControl {
                        left = relateItem.amount
                    }
                    
                    if let attributeItem = relateItem.target as? YHAsyncMutableAttributedItem {
                        
                        if let _ = self.attributeItemDic[attributeItem.hashValue] {
                        } else {
                            self.computeAttributeItemFrame(attributeItem)
                        }
                        
                        if relateItem.attributes == .left {
                            left = attributeItem.relatedConstraintRect.origin.x
                        }
                        
                        if relateItem.attributes == .right {
                            left = attributeItem.relatedConstraintRect.origin.y + attributeItem.relatedConstraintRect.size.width
                        }
                        
                        left = left + relateItem.amount
                    }
                    frame.origin.x = left
                }
            }
            
            if constraintItem.attributes == .right {
                
                if let relateItem = constraintItem.relateItem {
                    var right:CGFloat = 0
                    if let view = relateItem.target as? YHAsyncCanvasControl {
                        right = relateItem.amount
                    }
                    
                    if let attributeItem = relateItem.target as? YHAsyncMutableAttributedItem {
                        
                        if let _ = self.attributeItemDic[attributeItem.hashValue] {
                        } else {
                            self.computeAttributeItemFrame(attributeItem)
                        }
                        
                        if relateItem.attributes == .left {
                            right = attributeItem.relatedConstraintRect.origin.y
                        }
                        
                        if relateItem.attributes == .right {
                            right = attributeItem.relatedConstraintRect.origin.y + attributeItem.relatedConstraintRect.size.height
                        }
                        
                        right = right + relateItem.amount
                    }
                    
                    let width = self.canvasDrawerView.frame.size.width
                    frame.origin.x = width - right - frame.size.width
                }
            }
        }
        self.attributeItemDic[item.hashValue] = item
        item.relatedConstraintRect = frame
    }
}
