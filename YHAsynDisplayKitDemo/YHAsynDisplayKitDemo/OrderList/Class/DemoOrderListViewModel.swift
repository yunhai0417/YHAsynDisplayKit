//
//  DemoOrderListViewModel.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/24.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class DemoOrderListViewModel: YHAsyncBaseViewModel {
    override func refreshCellDataWithMetaData(_ item: YHAsyncBusinessModel) -> YHAsyncBaseCellData? {
        guard let orderItem = item as? DemoOrderModel else {
            return nil
        }
        return self.refreshCellDataWithMetaData(orderItem)
    }
    
    
    func refreshCellDataWithMetaData(_ orderItem:DemoOrderModel) -> YHAsyncBaseCellData {
        let cellData = DemoOrderCellData.init()
        
        cellData.cellHeight = 215
        cellData.cellWidth = UIScreen.main.bounds.size.width - 20
        
        //icon
        let poiImageAttributeItem = YHAsyncMutableAttributedItem.itemWithText("")
        if let poiPic = orderItem.poiPic {
            let imageAttributeItem = poiImageAttributeItem.appendImageWithUrl(poiPic, inSize: CGSize.init(width: 70, height: 70))
            if let imageAttachment = imageAttributeItem.arrayAttachments?.first {
                imageAttachment.baselineFontMetrics = YHAsyncFontMetricsCreateMakeWithLineHeight(YHAsyncFontMetricsCreateMake(UIFont.systemFont(ofSize: 11)), targetLineHeight: floor(imageAttachment.size.height))
            }
        }

        let poiImageDrawObject = YHAsyncVisionObject.init()
        poiImageDrawObject.visionFrame = CGRect.init(x: 15, y: 15, width: 70, height: 70)
        poiImageDrawObject.visionValue = poiImageAttributeItem

        cellData.textDrawerDatas.append(poiImageDrawObject)

//        //商家名称
//        let titleAttributeItem = YHAsyncMutableAttributedItem.itemWithText(orderItem.poiName)
//        titleAttributeItem.setFont(UIFont.systemFont(ofSize: 15))
//        titleAttributeItem.setColor(UIColor.black)
//        let titleDrawObject = YHAsyncVisionObject.init()
//        if let titleSize = titleAttributeItem.resultString?.attributedSize() {
//            let titleWidth = titleSize.width > 180 ? 180 : titleSize.width
//            let titleHeight = titleSize.height
//            titleDrawObject.visionFrame = CGRect.init(x: 60, y: 14, width:titleWidth, height: titleHeight)
//            titleDrawObject.visionValue = titleAttributeItem
//            cellData.textDrawerDatas.append(titleDrawObject)
//        }
//        
//        //商家箭头
//        let titleArrowAttributedItem = YHAsyncMutableAttributedItem.itemWithImageName("icon_arrow_store", inSize: CGSize.init(width: 10, height: 18))
//        titleArrowAttributedItem.setFont(UIFont.systemFont(ofSize: 12))
//        
//        let titleArrowDrawObject = YHAsyncVisionObject.init()
//        titleArrowDrawObject.visionValue = titleArrowAttributedItem
//        let titleArrowOriginX = titleDrawObject.visionFrame.size.width + titleDrawObject.visionFrame.origin.x
//        let titleArrowOriginY = titleDrawObject.visionFrame.origin.y
//        if let size = titleArrowAttributedItem.resultString?.attributedSize() {
//            titleArrowDrawObject.visionFrame = CGRect.init(x: titleArrowOriginX, y: titleArrowOriginY, width: 11, height: 26)
//        }
//        
//        
//        cellData.textDrawerDatas.append(titleArrowDrawObject)
//        
//        //订单状态
//        let statusAttributedItem = YHAsyncMutableAttributedItem.itemWithText(orderItem.statusDescription)
//        statusAttributedItem.setFont(UIFont.systemFont(ofSize: 15))
//
//        let statusDrawObject = YHAsyncVisionObject.init()
//        statusDrawObject.visionValue = statusAttributedItem
//
//        if let statusSize = statusAttributedItem.resultString?.attributedSize() {
//            let originx = cellData.cellWidth - statusSize.width - 15
//            statusDrawObject.visionFrame = CGRect.init(x: originx, y: 24, width: statusSize.width, height: statusSize.height)
//        }
//        cellData.textDrawerDatas.append(statusDrawObject)
//
//        //满减信息
//        let activityListAttributedItem = YHAsyncMutableAttributedItem.itemWithText(nil)
//        activityListAttributedItem.setFont(UIFont.systemFont(ofSize: 10))
//        activityListAttributedItem.setAlignment(YHAsyncTextAlignment.left, lineBreakMode: NSLineBreakMode.byTruncatingTail)
//        
//        for labelInfo in orderItem.labelList {
//            let labelAttributedItem = YHAsyncMutableAttributedItem.itemWithText(labelInfo.content)
//            labelAttributedItem.setColor(UIColor.green)
//            if let labelSize = labelAttributedItem.resultString?.attributedSize() {
//                let borderImageSize = CGSize.init(width: labelSize.width + 4, height: labelSize.height + 2)
//                let borderImage = UIImage.imageCreateWithColor(UIColor.clear, inSize: borderImageSize, borderWidth: 0.5, inBorderColor: UIColor.yellow, cornerRadius: 0)
//                
//                let image = borderImage?.yh_drawItem(labelAttributedItem, atPosition: CGPoint.init(x: 2, y: 1))
//                let borderLabelAttributedItem = YHAsyncMutableAttributedItem.itemWithText(nil)
//                _ = borderLabelAttributedItem.appendImageWithImage(image, inSize: labelSize)
//                
//                _ = activityListAttributedItem.appendAttributedItem(borderLabelAttributedItem)
//            }
//        }
//        
//        let activityListObject = YHAsyncVisionObject.init()
//        activityListObject.visionValue = activityListAttributedItem
//        let activityOriginX = titleDrawObject.visionFrame.origin.x
//        let activityOriginY = titleDrawObject.visionFrame.origin.y + titleDrawObject.visionFrame.size.height + 4
//        
//        activityListObject.visionFrame = CGRect.init(x: activityOriginX, y: activityOriginY, width: 275, height: 26)
//        cellData.textDrawerDatas.append(activityListObject)
//        
//        
//        //分隔线
//        let lineAttributedItem = YHAsyncMutableAttributedItem.itemWithText(nil)
//        let lineImage = UIImage.imageCreateWithColor(UIColor.gray, inSize: CGSize.init(width: cellData.cellWidth - 75, height: 0.5))
//        lineAttributedItem.appendImageWithImage(lineImage, inSize: CGSize.init(width: cellData.cellWidth - 75, height: 0.5))
//        
//        
//        
//        let lineDrawObject = YHAsyncVisionObject.init()
//        lineDrawObject.visionValue = lineAttributedItem
//        let lineOriginX = titleDrawObject.visionFrame.origin.x
//        let lineOriginY = activityListObject.visionFrame.origin.y + activityListObject.visionFrame.size.height + 5
//        
//        lineDrawObject.visionFrame = CGRect.init(x: lineOriginX, y: lineOriginY, width: cellData.cellWidth - 75 + 1, height: 26)
//        
//        //食物
//        let foodInfo = orderItem.productList.first
//        let foodAttributedItem = YHAsyncMutableAttributedItem.itemWithText(foodInfo?.productName)
//        foodAttributedItem.setFont(UIFont.systemFont(ofSize: 15))
//        
//        let foodTextSize = foodAttributedItem.resultString?.attributedSize() ?? CGSize.zero
//        
//        let totalPriceAttibutedText = YHAsyncMutableAttributedItem.itemWithText(orderItem.totalPrice)
//        totalPriceAttibutedText.setFont(UIFont.systemFont(ofSize: 15))
//        totalPriceAttibutedText.setColor(UIColor.gray)
//        
//        let totalPriceSize = totalPriceAttibutedText.resultString?.attributedSize() ?? CGSize.zero
//        
//        let foodAttributeSpaceWidth = cellData.cellWidth - totalPriceSize.width - foodTextSize.width - 60 - 15
//        foodAttributedItem.appendWhiteSpaceWithWidth(foodAttributeSpaceWidth)
//        foodAttributedItem.appendAttributedItem(totalPriceAttibutedText)
//        
//        let foodDrawObject = YHAsyncVisionObject.init()
//        foodDrawObject.visionValue = foodAttributedItem
//        foodDrawObject.visionFrame = CGRect.init(x: titleDrawObject.visionFrame.origin.x,
//                                                 y: lineDrawObject.visionFrame.origin.y + lineDrawObject.visionFrame.size.height + 18,
//                                                 width: cellData.cellWidth - titleDrawObject.visionFrame.origin.x,
//                                                 height: totalPriceSize.height + 7)
//        cellData.textDrawerDatas.append(foodDrawObject)
//        
//        
//        //按钮列表
//        let buttonListAttributedItem = YHAsyncMutableAttributedItem.itemWithText(nil)
//        buttonListAttributedItem.setAlignment(YHAsyncTextAlignment.right)
//        for buttonInfo in orderItem.buttonList {
//            let labelAttributedItem = YHAsyncMutableAttributedItem.itemWithText(buttonInfo.title)
//            labelAttributedItem.setFont(UIFont.systemFont(ofSize: 15))
//            labelAttributedItem.setColor(UIColor.gray)
//            
//            let textSize = labelAttributedItem.resultString?.attributedSize() ?? CGSize.zero
//            
//            var borderImage:UIImage?
//            
//            if buttonInfo.highlight {
//                borderImage = UIImage.imageCreateWithColor(UIColor.blue, inSize: CGSize.init(width: 73, height: 32), borderWidth: 0, inBorderColor: nil, cornerRadius: 2)
//            } else {
//                borderImage = UIImage.imageCreateWithColor(UIColor.white, inSize: CGSize.init(width: 73, height: 32), borderWidth: 0, inBorderColor: UIColor.gray, cornerRadius: 2)
//            }
//            
//            let image = borderImage?.yh_drawItem(labelAttributedItem, atPosition: CGPoint.init(x: (73 - textSize.width ) * 0.5, y: (32 - textSize.height) * 0.5))
//            
//            let buttonAttributedItem = YHAsyncMutableAttributedItem.itemWithText(nil)
//            buttonAttributedItem.appendImageWithImage(image, inSize: CGSize.init(width: 73, height: 32))
//            buttonListAttributedItem.appendAttributedItem(buttonAttributedItem)
//            buttonListAttributedItem.appendWhiteSpaceWithWidth(10)
//            
//            buttonAttributedItem.setUserInfo(buttonInfo.title as AnyObject?)
//            
//            if let owner = self.owner {
//                buttonAttributedItem.addTarget(self, action: #selector(buttonDidClick(_:)), forControlEvents: UIControl.Event.touchUpInside)
//            }
//        }
//        
//        buttonListAttributedItem.setUserInfo("按钮空白" as AnyObject, priority:  1)
//        buttonListAttributedItem.addTarget(self, action: #selector(buttonDidClick(_:)), forControlEvents: UIControl.Event.touchUpInside, priority: 1)
//        
//        let buttonListSize = buttonListAttributedItem.resultString?.attributedSize() ?? CGSize.zero
//        let buttonListObject = YHAsyncVisionObject.init()
//        
//        buttonListObject.visionFrame = CGRect.init(x: cellData.cellWidth - buttonListSize.width,
//                                                   y: foodDrawObject.visionFrame.origin.y + foodDrawObject.visionFrame.size.height + 22,
//                                                   width: buttonListSize.width,
//                                                   height: 32)
//        buttonListObject.visionValue = buttonListAttributedItem
//        cellData.textDrawerDatas.append(buttonListObject)
//        
//        cellData.cellHeight = buttonListObject.visionFrame.origin.y + buttonListObject.visionFrame.size.height + 14
        
        return cellData
    }

    @objc func buttonDidClick(_ userInfo:AnyObject?) {
        print("buttonDidClick")
    }
}
