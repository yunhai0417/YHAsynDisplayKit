//
//  DemoOrderModel.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit


class DemoOrderButtonInfo: NSObject {
    var title:String?
    var highlight:Bool = false
    
    init(_ dict:NSDictionary) {
        super.init()
        self.title = dict.object(forKey: "title") as? String
        self.highlight = dict.object(forKey: "highlight") as? Bool ?? false
    }
}

class DemoOrderProductInfo: NSObject {
    var productName:String?
    var productCount:NSInteger = 0
    
    init(_ dict:NSDictionary) {
        super.init()
        self.productName = dict.object(forKey: "food_name") as? String
        self.productCount = dict.object(forKey: "food_count") as? NSInteger ?? 0
    }
}

class DemoOrderLabelInfo: NSObject {
    var content:String?
    var contentColor:String?
    var labelFrameColor:String?
    init(_ dict:NSDictionary) {
        super.init()
        
        self.content = dict.object(forKey: "content") as? String
        self.contentColor = dict.object(forKey: "content_color") as? String
        self.labelFrameColor = dict.object(forKey: "label_frame_color") as? String
    }
    
}

class DemoOrderModel: YHAsyncBusinessModel {
    var poiPic:String?
    var poiName:String?
    var statusDescription:String?
    var totalPrice:String?
    
    var buttonList:[DemoOrderButtonInfo] = [DemoOrderButtonInfo]()
    var productList:[DemoOrderProductInfo] = [DemoOrderProductInfo]()
    var labelList:[DemoOrderLabelInfo] = [DemoOrderLabelInfo]()
    
    init(_ dict:NSDictionary) {
        super.init()
        
        self.poiPic = dict.object(forKey: "business_pic") as? String
        self.poiName = dict.object(forKey: "business_name") as? String
        self.statusDescription = dict.object(forKey: "status_description") as? String
        let tPrice = (dict.object(forKey: "total") as? CGFloat) ?? 0
        self.totalPrice = "￥\(tPrice)"
        
        self.buttonList.removeAll()
        if let buttonJSONArr = dict.object(forKey: "button_list") as? NSArray {
            for bDic in buttonJSONArr {
                if let dictButton = bDic as? NSDictionary {
                    let buttonInfo = DemoOrderButtonInfo.init(dictButton)
                    buttonList.append(buttonInfo)
                }
            }
        }
        
        self.productList.removeAll()
        if let productJSONArr = dict.object(forKey: "food_list") as? NSArray {
            for bDic in productJSONArr {
                if let product = bDic as? NSDictionary {
                    let productInfo = DemoOrderProductInfo.init(product)
                    productList.append(productInfo)
                }
            }
        }
        
        self.labelList.removeAll()
        if let labelJsonDict = dict.object(forKey: "business_extension_info") as? NSDictionary {
            if let labelJsonArr = labelJsonDict.object(forKey: "business_label_info") as? NSArray {
                for bDic in labelJsonArr {
                    if let label = bDic as? NSDictionary {
                        let labelInfo = DemoOrderLabelInfo.init(label)
                        labelList.append(labelInfo)
                    }
                }
            }
        }
    }
}
