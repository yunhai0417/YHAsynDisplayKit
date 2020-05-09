//
//  YHAsyncTextAttachment.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/5.
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

//MARK: 富文本数据模型
public class YHAsyncTextAttachment: NSObject, YHAsyncAttachmentProtocol {
    
    public var callBacks = [attributeCallBack]()
    
    //附件类型
    public var type: YHAsyncAttachmentType = .None
    //附件Size
    public var size: CGSize = CGSize.zero
    
    public var edgeInsets: UIEdgeInsets?
    public func getEdgeInsets() -> UIEdgeInsets? {
        guard let baselineFontMetrics = self.baselineFontMetrics else {
            return self.edgeInsets
        }
        
        guard let edgeInsets = self.edgeInsets else {
            return self.edgeInsets
        }
        
        if self.retriveFontMetricsAutomatically {
            let lineHeight:CGFloat = YHAsyncFontMetricsGetLineHeight(baselineFontMetrics)
            let inset:CGFloat = (lineHeight - size.height ) / 2
            
            return UIEdgeInsets.init(top: inset, left: edgeInsets.left, bottom: inset, right: edgeInsets.right)
        }
        return edgeInsets
    }
    
    public func placeholderSize() -> CGSize? {
        guard let edgeInsets = self.edgeInsets else { return nil }
        
        return CGSize.init(width: self.size.width + edgeInsets.left + edgeInsets.right,
                           height: self.size.height + edgeInsets.top + edgeInsets.bottom)
    }
    
    public var contents: AnyObject!
    
    public var contentString: String?
    public var contentImage: UIImage?
    public var contentAsyncImage: YHAsyncImage?
    
    public var position: UInt?
    
    public var length: UInt?
    
    //基线fontMetrics
    public var baselineFontMetrics: YHAsyncFontMetrics?
    
//MARK: Touch Event
    // 文本组件触发事件的target
    public weak var target:AnyObject?
    // 文本组件触发的事件回调
    public var selector:Selector?
    // 文本组件是否响应事件，默认responseEvent = （target && selector && target respondSelector:selector）
    public var responseEvent:Bool = false
    
    // 给 attachment 绑定的自定义信息
    public var userInfo:AnyObject?
    
    // userInfo 绑定的优先级
    public var userInfoPriority:NSInteger = 0
    
    // event 绑定的优先级
    public var eventPriority:NSInteger = 0
    
    /**
    *  构建一个文本组件的类方法
    *
    * @param contents  文本组件表达的内容、样式
    * @param type 文本组件类型
    * @param size  该组件占用大小
    *
    */
    
    public class func textAttachmentWithContents(_ contents:AnyObject?, inType type:YHAsyncAttachmentType, inSize size:CGSize) -> YHAsyncTextAttachment {
        let att = YHAsyncTextAttachment(type)
            if let contents = contents {
                att.contents = contents
            }
            att.type = type
            att.size = size
        return att
    }
    
    //我们需要给每个文本组件设定对应的FontMetrics，默认为YES。框架会自动获取各个插入组件的Metrics信息
    public var retriveFontMetricsAutomatically:Bool = true
    
    // 框架内部会在合适时机设置文本组件的展示Frame，注意！我们不需要指定该值~
    public var layoutFrame:CGRect?
    
    override init() {
        super.init()
        self.retriveFontMetricsAutomatically = true
        self.baselineFontMetrics = YHAsyncFontMetricsZero
        
        //设置默认边距=> 距离左边距离
        self.edgeInsets = UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 0)
    }
    
    
    init(_ type:YHAsyncAttachmentType) {
        super.init()
        self.retriveFontMetricsAutomatically = true
        self.baselineFontMetrics = YHAsyncFontMetricsZero
        if type == YHAsyncAttachmentType.StaticImage {
            self.edgeInsets = UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 0)
        } else {
            self.edgeInsets = UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 0)
        }
    }
    
    /**
    *  给一个文本组件添加事件
    *
    * @param target 事件执行者
    * @param action 事件行为
    * @param controlEvents 事件类型
    *
    */
    public func addTarget(_ target:AnyObject?, inAction action:Selector?, forControlEvents controlEvents:UIControl.Event) {
        self.target = target
        self.selector = action
        
        self.responseEvent = false
        if let target = target , let action = action {
            self.responseEvent = target.responds(to: action)
        }
    }
    
    /**
    *  给一个文本组件添加点击回调
    *
    * @param callBack 点击事件执行回调
    *
    */
    public func registerClickBlock(_ incallBack:attributeCallBack?) {
        if let callBack = incallBack {
            self.callBacks.append(callBack)
        }
    }
    
    /**
    *  处理事件，框架内部使用
    */
    
    public func handleEvent(_ sender:AnyObject?) {
        if let target = self.target , let action = self.selector {
            if target.responds(to: action) {
                target.perform(action, with: selector)
            }
        }
        
        for callBack in self.callBacks {
            callBack()
        }
    }
}
