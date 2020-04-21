//
//  UIDevice+DisplayKit.swift
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

// MARK: - 设备的型号
extension UIDevice {
    
    /// 具体的设备的型号
    public class var deviceType: String {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        //------------------------------iTouch------------------------
        case "iPod1,1":                                 return "iPod Touch"
        case "iPod2,1":                                 return "iPod Touch 2"
        case "iPod3,1":                                 return "iPod Touch 3"
        case "iPod4,1":                                 return "iPod Touch 4"
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        //------------------------------iPhone---------------------------
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,2":                              return "iPhone Xs"
        case "iPhone11,4", "iPhone11,6":                return "iPhone Xs Max"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone12,1":                              return "iPhone 11"
        case "iPhone12,3":                              return "iPhone 11 Pro"
        case "iPhone12,5":                              return "iPhone 11 Pro Max"
            
        //------------------------------iPad--------------------------
        case "iPad1,1":                                 return "iPad 1"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7-inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9-inch"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad7,11", "iPad7,12":                    return "iPad 6"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9-inch 2"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5-inch"
        //------------------------------iPad Mini-----------------------
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        
        //------------------------------Samulitor-------------------------------------
        case "AppleTV5,3", "AppleTV6,2":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
            
        }
    }
}

// MARK: - 手机系列判断
extension UIDevice {
    /// 是否是iPhone系列
    public class var iPhoneSeries: Bool {
        return current.userInterfaceIdiom == .phone
    }
    
    /// 是否是iPad系列
    public class var iPadSeries: Bool {
        return current.userInterfaceIdiom == .pad
    }
    
    /// 是否是iPhone 4.7系列手机
    public class  var isPhone4_7Serier: Bool {
        return UIScreen.main.bounds.width == 375.0
    }
    
    /// 是否是iPhone 5.5系列手机
    public class var isPhone5_5Series: Bool {
        return UIScreen.main.bounds.width == 414.0
    }
    
    /// 是否是iPhone X手机
    public class var isPhoneXSerise: Bool {
        return deviceType == Info.iPhoneX
    }
    
    /// 是否是全屏系列 目前可以通过状态栏的高度为20 或者 44来判断 为后面的新的全屏机做准备
    public class var isFullScreenSerise: Bool {
        return UIApplication.shared.statusBarFrame.height == 44.0
    }
    
}

// MARK: - 手机信息
extension UIDevice {
    /// uudi 注意其实uuid并不是唯一不变的
    public class var uuid: String? {
        return current.identifierForVendor?.uuidString
    }
    
    /// 设备系统名称
    public class var deviceSystemName: String {
        return current.systemName
    }
    
    /// 设备名称
    public class var deviceName: String {
        return current.name
    }
    
    /// 设备版本
    public class var deviceSystemVersion: String {
        return current.systemVersion
    }
    
    /// 设备版本的Float类型, 如果等于-1了那么就说明转换失败了
    public class var deviceFloatSystemVersion: Float {
        return Float(deviceSystemVersion) ?? -1.0
    }
}

// MARK: - 字符串常量化
extension UIDevice {
    public struct Info {
        public static let iPodTouch5 = "iPod Touch 5"
        
        public static let iPodTouch6 = "iPod Touch 6"
        
        public static let iPhone4 = "iPhone 4"
        
        public static let iPhone4s = "iPhone 4s"
        
        public static let iPhone5 = "iPhone 5"
        
        public static let iPhone5c = "iPhone 5c"
        
        public static let iPhone5s = "iPhone 5s"
        
        public static let iPhone6 = "iPhone 6"
        
        public static let iPhone6Plus = "iPhone 6 Plus"
        
        public static let iPhone6s = "iPhone 6s"
        
        public static let iPhone6sPlus = "iPhone 6s Plus"
        
        public static let iPhoneSE = "iPhone SE"
        
        public static let iPhone7 = "iPhone 7"
        
        public static let iPhone7Plus = "iPhone 7 Plus"
        
        public static let iPhone8 = "iPhone 8"
        
        public static let iPhone8Plus = "iPhone 8 Plus"
        
        public static let iPhoneX = "iPhone X"
        
        public static let iPhoneXs = "iPhone Xs"
        
        public static let iPhoneXsMax = "iPhone Xs Max"
        
        public static let iPhoneXR = "iPhone XR"
        
        public static let iPad2 = "iPad 2"
        
        public static let iPad3 = "iPad 3"
        
        public static let iPad4 = "iPad 4"
        
        public static let iPadAir = "iPad Air"
        
        public static let iPadAir2 = "iPad Air 2"
        
        public static let iPadMini = "iPad Mini"
        
        public static let iPadMini2 = "iPad Mini 2"
        
        public static let iPadMini3 = "iPad Mini 3"
        
        public static let iPadMini4 = "iPad Mini 4"
        
        public static let iPadPro = "iPad Pro"
        
        public static let AppleTV = "Apple TV"
        
        public static let Simulator = "Simulator"
    }
}

