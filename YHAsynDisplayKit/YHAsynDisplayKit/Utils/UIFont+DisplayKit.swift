//
//  UIFont+DisplayKit.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/13.
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
import CoreText


var cachedFontDescriptors:NSDictionary?
var systemFontName:String?

var arialUniDescFallback:CTFontDescriptor? = nil;
var emojiDescFallback:CTFontDescriptor? = nil;
var dingbatsDescFallback:CTFontDescriptor? = nil;
var chineseDescFallback:CTFontDescriptor? = nil;
var lastResortDescFallback:CTFontDescriptor? = nil;

extension UIFont {
    /**
    * 根据字体大小获取系统字体
    *
    * @param size 字体大小
    *
    * @return 系统CTFont
    */
    class func yh_newSystemCTFontOfSize(_ fontSize:CGFloat) -> CTFont? {
        return CTFontCreateUIFontForLanguage(CTFontUIFontType.system, fontSize, nil)
    }
    
    /**
    * 根据字体大小获取一个bold类型的系统字体
    *
    * @param size 字体大小
    *
    * @return bold类型的系统CTFont
    */
    class func yh_newBoldSystemCTFontOfSize(_ fontSize:CGFloat) -> CTFont? {
        return CTFontCreateUIFontForLanguage(CTFontUIFontType.emphasizedSystem, fontSize, nil)
    }
    
    /**
    * 根据字体名称、字体大小获取一个CTFont类型的字体
    *
    * @param fontName 字符串类型，字体名称
    * @param fontSize 字体大小
    *
    * @return CTFont类型的字体
    */
    
    class func yh_newCTFontWithName(_ fontName:String, size fontSize:CGFloat) -> CTFont? {
        YHSynchoronized(token: self) {
            if let _ = cachedFontDescriptors {
                self.yh_createFontDescriptors()
            }
        }
        
        var desc:CTFontDescriptor? = cachedFontDescriptors?.object(forKey: fontName) as! CTFontDescriptor
        
        if desc == nil {
            desc = self.yh_newFontDescriptorForName(fontName)
        }
        
        let font:CTFont = CTFontCreateWithFontDescriptor(desc!, fontSize, nil)
        
        return font
    }
    
    /**
    * 获取某一字体的Bold类型的字体
    *
    * @param ctFont 待转换的CTFontRef类型字体
    *
    * @return bold类型的CTFont
    */
    
    class func yh_newBoldCTFontForCTFont(_ ctFont:CTFont) -> CTFont? {
        return self.yh_newCTFontWithCTFont(ctFont, symbo: CTFontSymbolicTraits.boldTrait)
    }
    
    /**
    * 获取某一字体的Italic类型的字体
    *
    * @param ctFont 待转换的CTFontRef类型字体
    *
    * @return italic类型的CTFont
    */
    
    class func yh_newItalicCTFontForCTFont(_ cfFont:CTFont) -> CTFont? {
        
        return self.yh_newCTFontWithCTFont(cfFont, symbo: CTFontSymbolicTraits.italicTrait)
    }
    
    /**
    * 根据指定的字体符号特性对CTFont进行转换
    *
    * @param ctFont 待转换的CTFontRef类型字体
    *
    * @return 完成字体符号特性转换的CTFont
    */
    
    class func yh_newCTFontWithCTFont(_ ctFont:CTFont, symbo symbolicTraits:CTFontSymbolicTraits?) -> CTFont? {
        guard let symbolicTraits = symbolicTraits else { return ctFont }
        
        var transfrom = CGAffineTransform.identity
        
        if symbolicTraits == CTFontSymbolicTraits.italicTrait {
            // 由于字体fallback的原因，直接使用 italicTrait 无法将中文变为斜体
            // 使用 transform 来实现倾斜效果, c = [0, 1]
            transfrom.c = 0.22
        }
        
        
        return CTFontCreateCopyWithSymbolicTraits(ctFont, CTFontGetSize(ctFont), &transfrom, symbolicTraits, symbolicTraits)
    }
    
    /**
    * 根据CTFont转换成UIFont
    *
    * @param CTFont CTFontRef类型的字体
    *
    * @return UIFont类型的字体
    */
    
    class func yh_fontWithCTFont(_ ctFont:CTFont) -> UIFont? {
        guard let fontName = CTFontCopyName(ctFont, kCTFontPostScriptNameKey) else { return nil}
        let fontSize = CTFontGetSize(ctFont)
        return UIFont.init(name: fontName as String, size: fontSize)
    }
    
    /**
    * 获取系统字体名称
    *
    * @return 系统字体名称 NSString类型
    *
    */
    
    class func yh_systemFontName() -> String {
        if let systemFontName = systemFontName {
            return systemFontName
        }
        let systemFontName1 = UIFont.systemFont(ofSize: 12).fontName
        systemFontName = systemFontName1
        return systemFontName1
    }
}


extension UIFont {
    class func yh_createFontDescriptors() {
        if let _ = arialUniDescFallback {
            arialUniDescFallback = nil
        }
        
        if let _ = emojiDescFallback {
            emojiDescFallback = nil
        }
        
        if let _ = dingbatsDescFallback {
            dingbatsDescFallback = nil
        }
        
        if let _ = chineseDescFallback {
            chineseDescFallback = nil
        }
        
        if let _ = lastResortDescFallback {
            lastResortDescFallback = nil
        }
        
        cachedFontDescriptors = nil
        // Unicode特殊字符 fallback
        let arialAttrs:NSDictionary = [kCTFontNameAttribute:"ArialMT"]
        arialUniDescFallback = CTFontDescriptorCreateWithAttributes(arialAttrs)
        
        // Emoji字符 fallback
        let emojiAttrs:NSDictionary = [kCTFontNameAttribute:"AppleColorEmoji"]
        emojiDescFallback = CTFontDescriptorCreateWithAttributes(emojiAttrs)
        
        let range:NSRange = NSRange.init(location: 0x2700, length: 0x27BF - 0x2700 + 1)
        let dingbatsSet:NSMutableCharacterSet = NSMutableCharacterSet.init(range: range)
        
        let dingBatsAttrs:NSDictionary = [kCTFontNameAttribute:"",kCTFontCharacterSetAttribute:dingbatsSet]
        dingbatsDescFallback = CTFontDescriptorCreateWithAttributes(dingBatsAttrs)
        
        if #available(iOS 9.0, *) {
            let pingfangAttrs:NSDictionary = [kCTFontNameAttribute:"PingFangSC-Regular"]
            chineseDescFallback = CTFontDescriptorCreateWithAttributes(pingfangAttrs)
        } else {
            // 中文字符fallback
            let range = NSRange.init(location: 0x4E00, length: 0x9FA5 - 0x4E00 + 1)
            var chineseCharacterSet:NSMutableCharacterSet = NSMutableCharacterSet.init(range: range)
            
            chineseCharacterSet.addCharacters(in: NSRange.init(location: 0x3000, length: 0x303F - 0x3000 + 1))
            chineseCharacterSet.addCharacters(in: NSRange.init(location: 0xFF00, length: 0xFFEF - 0xFF00 + 1))
            
            let heitiAttrs:NSDictionary = [kCTFontNameAttribute:"STHeitiSC-Light",kCTFontCharacterSetAttribute:chineseCharacterSet]
            
            chineseDescFallback = CTFontDescriptorCreateWithAttributes(heitiAttrs)
        }
        // 以上fallback未包含的字符，显示为"[?]"
        lastResortDescFallback = CTFontDescriptorCreateWithNameAndSize("LastResort" as CFString, 0)
        
        if #available(iOS 9.0, *) {
            let fontDescript = self.yh_newFontDescriptorForName(self.yh_systemFontName())
            cachedFontDescriptors = [self.yh_systemFontName():fontDescript]
        } else {
            
            let helveticaNeue = self.yh_newFontDescriptorForName("HelveticaNeue")
            
            cachedFontDescriptors = ["HelveticaNeue":helveticaNeue]
        }
    }
    
    class func yh_newFontDescriptorForName(_ name:String) -> CTFontDescriptor {
        var cascadeList = [CTFontDescriptor]()
        if let emojiDescFallback = emojiDescFallback {
           cascadeList.append(emojiDescFallback)
        }
        
        if let dingbatsDescFallback = dingbatsDescFallback {
           cascadeList.append(dingbatsDescFallback)
        }
        
        if let chineseDescFallback = chineseDescFallback {
           cascadeList.append(chineseDescFallback)
        }
        
        if let arialUniDescFallback = arialUniDescFallback {
           cascadeList.append(arialUniDescFallback)
        }
        
        /**
        *   对于以上cascadeList中的字体未包含的Unicode字符，
        *   CoreText会查找系统预设字体列表，若恰好某个包括粗体中文
        *   字形的字体也包含此特殊字符，可能导致此字符之后的中文变成粗体
        */
        
        let attrs:NSDictionary = [kCTFontNameAttribute:name,kCTFontCascadeListAttribute:cascadeList]
        
        return CTFontDescriptorCreateWithAttributes(attrs)
    }
}
