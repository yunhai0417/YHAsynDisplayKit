//
//  YHAsyncMutableAttributedItem.swift
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
import Foundation

//MARK: HAsyncMutableAttributedItemType 富文本类型
public enum YHAsyncMutableAttributedItemType:NSInteger {
    case MutableString = 1          //默认富文本类型
                    
    case StaticImage = 2            //图片类型
}


public typealias attributeCallBack = () -> Void

public struct YHAsyncMutableAttributedItemFlags {
    var needsRebuild:Bool = true
}

//MARK: 保存要展示的属性
public class YHAsyncMutableAttributedItem: NSObject {
    //属性状态
    public var attributeType:YHAsyncMutableAttributedItemType = .MutableString
    //依赖结果frame -> 直接放置到 YHAsyncVisionObject.visibleFrame
    public var relatedConstraintRect:CGRect = CGRect.zero
    
    fileprivate var itemFlags = YHAsyncMutableAttributedItemFlags()
    //保存文案属性
    fileprivate lazy var textStorage:NSMutableAttributedString = {
        let textStorage = NSMutableAttributedString.init()
        return textStorage
    }()
    // 视觉元素对应的resultString
    fileprivate var _resultString:NSAttributedString?
    public var resultString:NSAttributedString? {
        set {
            _resultString = newValue
        }
        get {
            self.rebuildIfNeeded()
            return _resultString
        }
    }
    
    // 视觉元素中涉及的文本组件
    fileprivate var _arrayAttachments:[YHAsyncTextAttachment]?
    public var arrayAttachments:[YHAsyncTextAttachment]? {
        set {
            _arrayAttachments = newValue
        }
        get {
            return _arrayAttachments
        }
    }
    
    
    //MARK: - func
    /**
    * 根据Text创建一个AttributedItem
    * @param text 文本
    * @return WMMutableAttributedItem
    * 如果输入nil 返回一个"" 空字符串创建
    */
    
    public class func itemWithText(_ inText:String?) -> YHAsyncMutableAttributedItem {
        if let text = inText {
            let item = YHAsyncMutableAttributedItem.init(text)
            return item
        }
        
        return YHAsyncMutableAttributedItem.init("")
        
    }
    
    /**
    * 根据imgname创建一个AttributedItem
    *
    * @param imgname 图片名称
    * @return WMMutableAttributedItem
    */
    
    public class func itemWithImageName(_ imgName:String) -> YHAsyncMutableAttributedItem {
        return YHAsyncMutableAttributedItem.itemWithImageName(imgName, inSize: CGSize.init(width: 15, height: 15))
    }
    
    /**
    * 根据指定size的imgname创建一个AttributedItem
    *
    * @param imgname 图片名字
    * @param size 图片大小
    * @return WMMutableAttributedItem
    */
    
    public class func itemWithImageName(_ imgName:String, inSize size:CGSize) -> YHAsyncMutableAttributedItem {
        let item = YHAsyncMutableAttributedItem.init("")
        item.appendImageWithName(imgName, inSize: size)
        return item
    }
    
    /**
    * 根据指定text初始化
    * @param text 文本
    * @return WMMutableAttributedItem
    */
    public init(_ text:String) {
        super.init()
        self.textStorage = NSMutableAttributedString.init(string: text)
        self.textStorage.yh_setFont(UIFont.systemFont(ofSize: 11))
        
        let attributedColor = YHAsyncColorManager.achieveColor(0x666666)
        
        self.textStorage.yh_setColor(attributedColor)
        
        self.resultString = nil
        
        self.arrayAttachments = [YHAsyncTextAttachment]()
        
        self.itemFlags.needsRebuild = true
    }
    
    /**
    * 设置AttributedItem的Font
    *
    * @param font 字体
    */
    
    public func setFont(_ font:UIFont) {
        self.setNeedsRebuild()
        self.textStorage.yh_setFont(font)
    }
    
    /**
    * 设置AttributedItem的Font
    *
    * @param size 字号
    * @param weight 字重
    * @param boldDisplay 是否加粗显示
    */
    
    public func setFontSize(_ size:CGFloat, fontWeight weight:CGFloat, boldDisplay display:Bool) {
        self.setNeedsRebuild()
        self.textStorage.yh_setFontSize(size, fontWeight: weight, boldDisplay: display)
    }
    
    /**
    * 设置AttributedItem的Font
    *
    * @param ctFont 字体
    */
    
    public func setCTFont(_ ctFont:CTFont) {
        self.setNeedsRebuild()
        self.textStorage.yh_setCTFont(ctFont)
    }
    
    /**
    * 设置AttributedItem的color
    *
    * @param color 颜色
    */
    
    public func setColor(_ color:UIColor) {
        self.setNeedsRebuild()
        self.textStorage.yh_setColor(color)
    }
    
    /**
    * 设置AttributedItem的对齐方式
    *
    * @param alignment 对齐方式
    */
    
    public func setAlignment(_ alignment:YHAsyncTextAlignment) {
        self.setNeedsRebuild()
        self.textStorage.yh_setAlignment(alignment)
    }
    
    /**
    * 设置AttributedItem的对齐方式
    *
    * @param alignment 对齐方式
    * @param lineBreakMode 换行模式
    *
    */
    
    public func setAlignment(_ alignment:YHAsyncTextAlignment, lineBreakMode mode:NSLineBreakMode) {
        self.setNeedsRebuild()
        self.textStorage.yh_setAlignment(alignment, lineBreakMode: mode)
    }
    
    /**
    * 设置AttributedItem的对齐方式
    *
    * @param alignment 对齐方式
    * @param lineBreakMode 换行模式
    * @param lineheight 行高
    *
    */
    public func setAlignment(_ alignment:YHAsyncTextAlignment, lineBreakMode mode:NSLineBreakMode, lineHeight height:CGFloat) {
        self.setNeedsRebuild()
        self.textStorage.yh_setAlignment(alignment, lineBreakMode: mode, lineHeight: height)
    }
    
    /**
    * 设置AttributedItem的排版字间距
    *
    * @param kern 字间距
    *
    */
    public func setKerning(_ kern:CGFloat) {
        self.setNeedsRebuild()
        self.textStorage.yh_setKerning(kern)
    }
    
    /**
    * 设置AttributedItem的连字风格
    *
    * @param textLigature 连字风格
    *
    */
    
    public func setTextLigature(_ textLigature:YHAsyncTextLigature) {
        self.setNeedsRebuild()
        self.textStorage.yh_setTextLigature(textLigature)
    }
    
    /**
    * 设置AttributedItem的下划线
    *
    * @param underlineStyle 下划线风格
    *
    */
    
    public func setUnderlineStyle(_ underlineStyle:YHAsyncTextUnderlineStyle) {
        self.setNeedsRebuild()
        self.textStorage.yh_setUnderlineStyle(underlineStyle)
    }
    
    /**
    * 设置AttributedItem的删除线
    *
    * @param strikeThroughStyle 删除线风格
    *
    */
    public func setStrikeThroughStyle(_ strikeThroughStyle:YHAsyncTextStrikeThroughStyle) {
        self.setNeedsRebuild()
        self.textStorage.yh_setStrikeThroughStyle(strikeThroughStyle)
    }
    
    /**
    * 设置AttributedItem的段落风格, 默认按照11号字进行段落设置
    *
    * @param paragraphStyle 段落风格
    *
    */
    public func setTextParagraphStyle(_ paragraphStyle:YHAsyncTextParagraphStyle) {
        self.setTextParagraphStyle(paragraphStyle, fontSize: 11)
    }
    
    /**
    * 设置AttributedItem的段落风格
    *
    * @param paragraphStyle 段落风格
    * @param fontSize 指定按照该字号进行段落风格设置
    *
    */
    
    public func setTextParagraphStyle(_ paragraphStyle:YHAsyncTextParagraphStyle, fontSize size:CGFloat) {
        self.setNeedsRebuild()
        self.textStorage.yh_setTextParagraphStyle(paragraphStyle, fontSize: size)
    }
    
    /**
    * 拼接一段文本
    *
    * @param text 文本
    * @return WMMutableAttributedItem
    *
    */
    
    public func appendText(_ text:String) -> YHAsyncMutableAttributedItem {
        var item = YHAsyncMutableAttributedItem.itemWithText(text)
        return self.appendAttributedItem(item)
    }
    
    /**
    * 拼接一段文本
    *
    * @param item WMMutableAttributedItem
    * @return WMMutableAttributedItem
    *
    */
    @discardableResult
    public func appendAttributedItem(_ item:YHAsyncMutableAttributedItem) -> YHAsyncMutableAttributedItem {
        if let resultString = item.resultString {
            if let arrayAttachments = item.arrayAttachments {
                for attachment in arrayAttachments {
                    let length = self.textStorage.length
                    if let position = attachment.position {
                        attachment.position = position + UInt(length)
                        self.arrayAttachments?.append(attachment)
                    }
                }
            }
            self.textStorage.append(resultString)
            self.setNeedsRebuild()
        }
        
        return self
    }
    
    /**
    * 拼接分割线，默认颜色0xc4c4c4
    *
    * @return WMMutableAttributedItem
    *
    */
    
    public func appendSeparatorLine() -> YHAsyncMutableAttributedItem {
        
        let color = YHAsyncColorManager.achieveColor(0xc4c4c4)
//            UIColor(red:((CGFloat)((0xc4c4c4 & 0xFF0000) >> 16)) / 255.0,
//                            green: ((CGFloat)((0xc4c4c4 & 0xFF00) >> 8)) / 255.0,
//                            blue: ((CGFloat)(0xc4c4c4 & 0xFF)) / 255.0,
//                            alpha: 1.0)
        
        return self.appendSeparatorLineWithColor(color)
    }
    
    /**
    * 拼接指定颜色分割线
    *
    * @return WMMutableAttributedItem
    *
    */
    
    public func appendSeparatorLineWithColor(_ color:UIColor) -> YHAsyncMutableAttributedItem {
        let image = UIImage.imageCreateWithColor(color, inSize: CGSize.init(width: 1, height: 7))
        
        let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.StaticImage, inSize: CGSize.init(width: 0.5, height: 7))
        att.retriveFontMetricsAutomatically = false
        
        let font = UIFont.systemFont(ofSize: 11)
        
        let fontMetric = YHAsyncFontMetricsCreateMake(font)
        att.baselineFontMetrics = fontMetric
        
        let lineHeight = YHAsyncFontMetricsGetLineHeight(fontMetric)
        
        let inset = (lineHeight - 7 ) / 2
        att.edgeInsets = UIEdgeInsets.init(top: inset - 1, left: 3, bottom: inset - 1, right: 3)
        
        return self.appendAttachment(att)
    }
    
    /**
    * 拼接指定Url的图片
    * @param imgUrl 图片Url
    * @param size 图片size 默认size (11, 11)
    * @return WMMutableAttributedItem
    */
    
    @discardableResult
    public func appendImageWithUrl(_ imgUrl:String, inSize size:CGSize = CGSize(width: 11, height: 11)) -> YHAsyncMutableAttributedItem {
        if imgUrl.isEmpty {
            return self
        }
        let image = YHAsyncImage.imageWithUrl(imgUrl)
        image?.size = size
        if self.attributeType == .MutableString {
            let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.StaticImage, inSize: size)
            return self.appendAttachment(att)
        } else {
            let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.OnlyImage, inSize: size)
            return self.appendAttachment(att)
        }
    }
    
    /**
    * 拼接指定Url的图片
    *
    * @param imgUrl 图片Url
    * @param placeholder 占位图
    *
    * @return WMMutableAttributedItem
    *
    */
    @discardableResult
    public func appendImageWithUrl(_ imgUrl:String, inPlaceholder placeholder:String) ->YHAsyncMutableAttributedItem {
        return self.appendImageWithUrl(imgUrl, inSize: CGSize.init(width: 11, height: 11), inPlaceholder: placeholder)
    }
    
    /**
    * 拼接指定Url的图片
    * @param imgUrl 图片Url
    * @param size 图片size
    * @param placeholder 占位图
    * @return WMMutableAttributedItem
    */
    @discardableResult
    public func appendImageWithUrl(_ imgUrl:String, inSize size:CGSize ,inPlaceholder placeholder:String) ->YHAsyncMutableAttributedItem {
        if imgUrl.isEmpty && placeholder.isEmpty {
            return self
        }
        
        let image = YHAsyncImage.init()
        image.downloadUrl = imgUrl
        image.image = UIImage.init(named: placeholder)
        image.size = size
        
        let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.StaticImage, inSize: size)
        
        return self.appendAttachment(att)
    }
    
    /**
    * 拼接指定名字的本地图片
    *
    * @param imgname 图片名称
    * @param size 图片size
    *
    * @return WMMutableAttributedItem
    *
    */
    @discardableResult
    public func appendImageWithName(_ imgName:String, inSize size:CGSize = CGSize(width: 11, height: 11)) -> YHAsyncMutableAttributedItem? {
        
        let image = UIImage.init(named: imgName)
        return self.appendImageWithImage(image, inSize: size)
    }
    
    /**
    * 拼接指定本地图片
    *
    * @param image 本地图片
    * @param size 图片size
    *
    * @return WMMutableAttributedItem
    *
    */
    
    @discardableResult
    public func appendImageWithImage(_ image:UIImage?, inSize size:CGSize = CGSize(width: 11, height: 11)) -> YHAsyncMutableAttributedItem {
        let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.StaticImage, inSize: size)
        
        return self.appendAttachment(att)
    }
    
    
    /**
    * 拼接指定本地图片
    *
    * @param image 本地图片
    * @param size  图片size
    * @param image UIEdgeInsets
    *
    * @return WMMutableAttributedItem
    *
    */
    @discardableResult
    public func appendImageWithImage(_ image:UIImage?, inSize size:CGSize = CGSize(width: 11, height: 11), imageEdge inEdgeInsets:UIEdgeInsets?) -> YHAsyncMutableAttributedItem {
        let att = YHAsyncTextAttachment.textAttachmentWithContents(image, inType: YHAsyncAttachmentType.StaticImage, inSize: size)
        if let edge = inEdgeInsets {
            att.edgeInsets = edge
        }
        return self.appendAttachment(att)
    }
    
    
    /**
    * 拼接一个指定宽度的空白占位
    *
    * @param width 空白占位宽度
    *
    * @return WMMutableAttributedItem
    *
    */
    @discardableResult
    public func appendWhiteSpaceWithWidth(_ width:CGFloat) -> YHAsyncMutableAttributedItem {
        let att = YHAsyncTextAttachment.textAttachmentWithContents(nil, inType: YHAsyncAttachmentType.Placeholder, inSize: CGSize.init(width: width, height: 1))
        
        return self.appendAttachment(att)
    }
    
    /**
    * 拼接一个文本组件
    * @param att 文本组件
    * @return WMMutableAttributedItem
    */
    @discardableResult
    public func appendAttachment(_ att:YHAsyncTextAttachment) -> YHAsyncMutableAttributedItem {
        if att.type == YHAsyncAttachmentType.StaticImage
            || att.type == YHAsyncAttachmentType.Placeholder {
            att.position = 0
            let length = self.textStorage.length
            if let position = att.position   {
                att.position = position + UInt(length)
            }
            att.length = 1
        }
        self.setNeedsRebuild()
        
        if let str = NSAttributedString.yh_attributedStringWithTextAttachment(att) {
            self.textStorage.append(str)
            if self.attributeType == .StaticImage && self.arrayAttachments?.count == 1 {
                print("拼接一个文本组件 失败")
                return self
            }
            self.arrayAttachments?.append(att)
        }
        return self
    }
    
    /**
    *  给 Item 绑定自定义信息,点击事件触发后会把信息回抛,优先级默认为0
    *
    * @param userInfo 自定义信息
    *
    */
    
    public func setUserInfo(_ userInfo:AnyObject?) {
        self.setUserInfo(userInfo, priority: 0)
    }
    
    /**
    *  给 Item 绑定自定义信息,点击事件触发后会把信息回抛
    *
    * @param userInfo 自定义信息
    * @param priority userInfo的优先级,数字越小优先级越高
    */
    public func setUserInfo(_ inUserInfo:AnyObject?, priority inPriority:NSInteger) {
        guard let userInfo = inUserInfo else { return }
        guard let arrayAttachments = self.arrayAttachments else { return }
        for attachMent in arrayAttachments {
            if inPriority <= attachMent.userInfoPriority {
                attachMent.userInfo = inUserInfo
                attachMent.userInfoPriority = inPriority
            }
        }
    }
    
    /**
    *  给一个文本组件添加事件,优先级默认为0
    *
    * @param target 事件执行者
    * @param action 事件行为
    * @param controlEvents 事件类型
    *
    */
    
    public func addTarget(_ target:AnyObject, action inAction:Selector, forControlEvents controlEvents:UIControl.Event) {
        self.addTarget(target, action: inAction, forControlEvents: controlEvents, priority: 0)
    }
    
    /**
    *  给一个文本组件添加事件
    *
    * @param target 事件执行者
    * @param action 事件行为
    * @param controlEvents 事件类型
    * @param priority 相应事件的优先级,数字越小优先级约高
    */
    
    public func addTarget(_ target:AnyObject, action inAction:Selector, forControlEvents controlEvents:UIControl.Event, priority inpriority:NSInteger) {
        if target.responds(to: inAction) {
            guard let arrayAttachments = self.arrayAttachments else { return }
            for attachMent in arrayAttachments {
                if inpriority <= attachMent.eventPriority {
                    attachMent.eventPriority = inpriority
                    attachMent.addTarget(target, inAction: inAction, forControlEvents: controlEvents)
                }
            }
        }
    }
    
    
    /**
    *  给一个文本组件添加点击回调
    *
    * @param callBack 点击事件执行回调
    *
    */
    
    public func registerClickBlock(_ inCallBack:attributeCallBack?) {
        guard let callBack = inCallBack  else { return }
        guard let arrayAttachments = self.arrayAttachments else { return }
        for attachMent in arrayAttachments {
            attachMent.registerClickBlock(inCallBack)
        }
    }
}



extension YHAsyncMutableAttributedItem {
    fileprivate func rebuildIfNeeded() {
        if itemFlags.needsRebuild {
            self.rebuild()
        }
    }
    
    fileprivate func setNeedsRebuild() {
        self.itemFlags.needsRebuild = true
    }
    
    fileprivate func rebuild() {
        self.itemFlags.needsRebuild = false
        let textStorage = self.textStorage
        
        if textStorage.length == 0 {
            return
        }
        
        let mstr = NSMutableAttributedString.init(string: textStorage.string)
        
        let keys:[NSAttributedString.Key] = [
            (kCTFontAttributeName as NSAttributedString.Key),
            (kCTForegroundColorAttributeName as NSAttributedString.Key),
            (kCTParagraphStyleAttributeName as NSAttributedString.Key),
            (kCTKernAttributeName as NSAttributedString.Key),
            (kCTUnderlineStyleAttributeName as NSAttributedString.Key),
            (kCTUnderlineColorAttributeName as NSAttributedString.Key),
            (kCTLigatureAttributeName as NSAttributedString.Key),
            NSAttributedString.Key.strikethroughStyle,
            NSAttributedString.Key.strikethroughColor,
            (kCTRunDelegateAttributeName as NSAttributedString.Key),
            NSAttributedString.Key(rawValue: YHAsyncMacroConfigKey.TextAttachmentAttributeName),
            NSAttributedString.Key(rawValue: YHAsyncTextKeyAttributeName.DefaultForegroundColor),
            NSAttributedString.Key(rawValue: YHAsyncTextKeyAttributeName.StrikethroughStyle),
            NSAttributedString.Key(rawValue: YHAsyncTextKeyAttributeName.StrikethroughColor)
        ]
        
        for key in keys {
            textStorage.enumerateAttribute(key, in: NSRange.init(location: 0, length: textStorage.length), options: []) { (value, range, stop) in
                if let value = value, range.location != NSNotFound {
                    mstr.addAttribute(key, value: value, range: range)
                }
            }
        }
        
        let attributeKey = YHAsyncMacroConfigKey.TextAttachmentAttributeName
        mstr.enumerateAttribute(NSAttributedString.Key(rawValue: attributeKey), in: NSRange.init(location: 0, length: mstr.length), options: []) { (value, range, stop) in
            if let value = value, let att = value as? YHAsyncTextAttachment {
                if att.retriveFontMetricsAutomatically && YHAsyncFontMetricsEqual(att.baselineFontMetrics, inMetricsRight: YHAsyncFontMetricsZero) {
                    var earlyMetrics = YHAsyncFontMetricsZero
                    // 先找前面，再找后面
                    if range.location > 0 && range.location != NSNotFound {
                        //前面
                        mstr.enumerateAttribute(kCTFontAttributeName as NSAttributedString.Key, in: NSRange.init(location: 0, length: range.location), options: NSAttributedString.EnumerationOptions.reverse) { (bValue, range, bstop) in
                            
                            if let bValue = bValue {
                                let font = bValue as! CTFont
                                earlyMetrics = YHAsyncFontMetricsCreateMake(font)
                                bstop.pointee = true
                            }
                        }
                        
                        if YHAsyncFontMetricsEqual(earlyMetrics, inMetricsRight: YHAsyncFontMetricsZero)
                        {
                            let range = NSRange.init(location: NSMaxRange(range), length: mstr.length - NSMaxRange(range))
                            mstr.enumerateAttribute(kCTFontAttributeName as NSAttributedString.Key, in: range, options: []) { (aValue, range, astop) in

                                if let aValue = aValue {
                                    let font = aValue as! CTFont
                                    earlyMetrics = YHAsyncFontMetricsCreateMake(font)
                                    astop.pointee = true
                                }
                            }
                            
                            if YHAsyncFontMetricsEqual(earlyMetrics, inMetricsRight: YHAsyncFontMetricsZero) {
                                let font = UIFont.systemFont(ofSize: 11)
                                earlyMetrics = YHAsyncFontMetricsCreateMake(font)
                            }
                            
                            att.baselineFontMetrics = earlyMetrics
                        } else {
                            att.baselineFontMetrics = earlyMetrics
                        }
                    } else {
                        //后面
                        let range = NSRange.init(location: NSMaxRange(range), length: mstr.length - NSMaxRange(range))
                        mstr.enumerateAttribute(kCTFontAttributeName as NSAttributedString.Key, in: range, options: []) { (aValue, range, astop) in

                            if let aValue = aValue {
                                let font = aValue as! CTFont
                                earlyMetrics = YHAsyncFontMetricsCreateMake(font)
                                astop.pointee = true
                            }
                        }
                        
                        if YHAsyncFontMetricsEqual(earlyMetrics, inMetricsRight: YHAsyncFontMetricsZero) {
                            let font = UIFont.systemFont(ofSize: 11)
                            earlyMetrics = YHAsyncFontMetricsCreateMake(font)
                        }
                        
                        att.baselineFontMetrics = earlyMetrics
                    }
                }
            }
        }
        self.resultString = mstr
    }
    
    
}
