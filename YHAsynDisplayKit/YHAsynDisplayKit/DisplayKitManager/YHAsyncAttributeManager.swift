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
    
    //创建管理类 非单例
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
        let mixView = YHAsyncMixedView.init(frame: CGRect.zero)
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
    public func bindAttributeWithCanvasView() -> CGSize {
        if let mixedView = self.canvasDrawerView as? YHAsyncMixedView {
            mixedView.attributedItem = self.attributeItemList.first
        }
//        self.canvasDrawerView.setNeedsDisplay()
        return self.attributeItemList[0].resultString?.attributedSize() ?? CGSize.zero
    }
}
