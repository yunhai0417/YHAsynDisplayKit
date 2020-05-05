//
//  AdvanceViewController.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/5/5.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import Foundation
import YHAsynDisplayKit
import SnapKit

class AdvanceViewController: UIViewController {
    
    fileprivate var displayManager:YHAsyncAttributeManager<YHAsyncMixedView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.testFunc1()
        
        
    }
    
    //MARK: 基础功能测试
    func testFunc1() {
        self.displayManager = YHAsyncAttributeManager<YHAsyncMixedView>.sharedInstance()
        guard let dispalyManager = self.displayManager else { return }
                
        let text1 = YHAsyncMutableAttributedImage.itemWithText("YHAsync")
        text1.setFont(UIFont.systemFont(ofSize: 16))
        text1.setColor(UIColor.white)
        guard let statusSize = text1.resultString?.attributedSize() else { return }

        let text2 = YHAsyncMutableAttributedImage.itemWithText("是一种高效的UI渲染框架")
        text2.setFont(UIFont.systemFont(ofSize: 16))
        text2.setColor(UIColor.blue)
        guard let descSize = text2.resultString?.attributedSizeConstrained(160, numberOfLines: 1) else { return }

        var contentImage1 = UIImage.imageCreateWithColor(UIColor.orange, inSize: CGSize.init(width: statusSize.width + 8.0, height: max(statusSize.height, descSize.height)))
                
        let rectCorner = UIRectCorner.init(rawValue: UIRectCorner.topLeft.rawValue | UIRectCorner.bottomLeft.rawValue)
                
        contentImage1 = contentImage1?.yh_roundedImageWithRadius(4, rectCornerType: rectCorner)

        contentImage1 = contentImage1?.yh_drawItem(text1, numberOfLines: 1, atPosition: CGPoint.init(x: 4, y: 1))

        let imageSize = CGSize(width: descSize.width - 8.0, height: max(statusSize.height, descSize.height))
        var contentImage2 = UIImage.imageCreateWithColor(UIColor.clear, inSize:imageSize , borderWidth:4, inBorderColor: UIColor.orange, cornerRadius: YHAsyncCornerRadiusMake(inTopLeft: 0, inTopRight: 4, inBottomLeft: 0, inBottomRight: 4))

        contentImage2 = contentImage2?.yh_drawItem(text2, numberOfLines: 1, atPosition: CGPoint.init(x: 4, y: 0))


        let text = dispalyManager.createAttributeItem()
        _ = text.appendImageWithImage(contentImage1,inSize: contentImage1!.size)
        _ = text.appendImageWithImage(contentImage2,inSize: contentImage2!.size, imageEdge:UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 0))
                
                
        dispalyManager.insertAttributeItem(text)
                
        let canvasView = dispalyManager.achieveCurrentCanvasView()
        self.view.addSubview(canvasView)
                
        //        canvasView.snp.makeConstraints { make in
        //            make.top.equalTo(self.view).offset(100)
        //            make.left.equalTo(self.view)
        //            make.size.equalTo(CGSize.init(width: 100, height: 100))
        //        }
        let size = dispalyManager.bindAttributeWithCanvasView()
        canvasView.frame = CGRect.init(x: 100, y: 100, width: size.width, height: size.height)
    }
}
