//
//  YHAsyncAttachment.swift
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

//MARK: 附件类型
public enum YHAsyncAttachmentType:NSInteger {
    case None        = 0
    case StaticImage = 1        //附件图片
    case Placeholder = 2        //附件占位符
    case OnlyImage   = 3        //单独图片
    case ApplicationReserved = 0xF000
}

/**
 *  Attachment 定义了一个特殊的attributedString字符，它可以被展示成特殊的大小、样式
 */

public protocol YHAsyncAttachmentProtocol: NSObjectProtocol {

    // 定义组件类型，一般文本中插入的图片被标记为StaticImage
    var type:YHAsyncAttachmentType { get set }

    // 组件展示相关的数据 一般为 NSString*、UIImage、YHAsyncImage
    // 分别对应图片名称（或者是一组文本）、本地图片、网络下载图片
    var contentString:String? { get set }
    var contentImage:UIImage? { get set }
    var contentAsyncImage:YHAsyncImage? { get set }
    
    // 组件展示相关的数据 一般为 NSString*、UIImage、YHAsyncImage
    // 分别对应图片名称（或者是一组文本）、本地图片、网络下载图片
    var contents:AnyObject! { get set }
    
    // 指定组件以size大小展示
    var size:CGSize { get set }
    
    // 组件和四周的edgeInsets
    var edgeInsets:UIEdgeInsets? { get set }
    
    // 指定组件在AttributedString中的位置和长度，对于图片组件而言，由于是用\u{fffc}表达，所以长度为1。
    var position:UInt? { get set }
    
    var length:UInt? { get set }
    
    var baselineFontMetrics:YHAsyncFontMetrics? { get set }
    
    func placeholderSize() -> CGSize?
}
