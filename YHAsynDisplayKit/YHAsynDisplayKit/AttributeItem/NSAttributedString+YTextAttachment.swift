//
//  NSAttributedString+YTextAttachment.swift
//  Pods-YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/13.
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

typealias YHAsyncTextAttachmentsWithBlock = (_ attachment:YHAsyncTextAttachment, _ range:NSRange, _ stop:UnsafeMutablePointer<ObjCBool>) -> Void
// AttributedString的文本组件分类
extension NSAttributedString {

    /**
    *  遍历AttributedString中的所有文本组件
    *
    * @param block 参数1 attachment 文本组件对象 参数2 range 该文本组件处于AtrributedString中的Range
    *
    */
    func yh_enumerateTextAttachmentsWithBlock(_ block:YHAsyncTextAttachmentsWithBlock?) {
        self.yh_enumerateTextAttachmentsWithOptions([], inBlock: block)
    }
    
    /**
    *  遍历AttributedString中的所有文本组件
    *
    * @param options 遍历选项
    * @param block 参数1 attachment 文本组件对象 参数2 range 该文本组件处于AtrributedString中的Range
    *
    */
    
    func yh_enumerateTextAttachmentsWithOptions(_ options:NSAttributedString.EnumerationOptions, inBlock block:YHAsyncTextAttachmentsWithBlock?) {
        guard let block = block else { return }
        
        let attrName = NSAttributedString.Key.init(rawValue: YHAsyncMacroConfigKey.TextAttachmentAttributeName)
        self.enumerateAttribute(attrName, in: NSRange.init(location: 0, length: self.length), options: options) { (attachment, range, stop) in
            if let attachment = attachment as? YHAsyncTextAttachment {
                block(attachment, range , stop)
            }
        }
    }
    
    /**
    *  根据文本组件创建一个对应的AttributedString
    *
    * @param attachment 文本组件
    *
    */
    
    public class func yh_attributedStringWithTextAttachment(_ attachment:YHAsyncTextAttachment) -> NSAttributedString? {
        let dic = [NSAttributedString.Key : Any]()
        return self.yh_attributedStringWithTextAttachment(attachment, inAttributes:dic)
    }
    
    /**
    *  根据文本组件创建一个对应的AttributedString
    *
    * @param attachment 文本组件
    * @param attributes 额外设置的属性
    *
    */
    
    public class func yh_attributedStringWithTextAttachment(_ attachment:YHAsyncTextAttachment, inAttributes attributes:[NSAttributedString.Key : Any]) -> NSAttributedString? {
        // Core Text 通过runDelegate确定非文字（attachment）区域的大小
        guard let runDelegate:CTRunDelegate? = YHAsyncTextLayoutRun.textLayoutRunWithAttachment(attachment) else {
            return nil
        }
        
        // 设置CTRunDelegateRef 和 文本颜色， 由于占位的“*”不需要显示，故设为透明色
        var placeholderAttributes = attributes
        
        let runDelegateAttributeName = NSAttributedString.Key.init(rawValue: kCTRunDelegateAttributeName as String)
        placeholderAttributes[runDelegateAttributeName] = runDelegate
        
        let foregroundColorAttributeName = NSAttributedString.Key.init(rawValue: kCTForegroundColorAttributeName as String)
        placeholderAttributes[foregroundColorAttributeName] = UIColor.clear.cgColor
        
        let textAttachment = NSAttributedString.Key.init(rawValue: YHAsyncMacroConfigKey.TextAttachmentAttributeName)
        placeholderAttributes[textAttachment] = attachment
        
        // 所有表情文本（如“[哈哈]”）替换为一个占位符，并通过CTRunDelegateRef控制大小
        let str = YHAsyncMacroConfigKey.TextAttachmentReplacementCharacter
        let result = NSAttributedString.init(string: str, attributes: placeholderAttributes as! [NSAttributedString.Key : Any])
        
        return result
    }
}

