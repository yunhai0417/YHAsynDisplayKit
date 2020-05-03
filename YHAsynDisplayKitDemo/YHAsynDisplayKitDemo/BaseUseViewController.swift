//
//  BaseUseViewController.swift
//  YHAsynDisplayKitDemo
//
//  Created by 吴云海 on 2020/4/16.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit
import YHAsynDisplayKit

class BaseUseViewController: UIViewController {
    
    var tempIndex:NSInteger = 0
    
    lazy var scrollView:UIScrollView = {
        let scrollview = UIScrollView.init(frame: self.view.frame)
        scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: 20000)
        scrollview.isScrollEnabled = true
        scrollview.showsVerticalScrollIndicator = true
        return scrollview
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.scrollView)
        
        if tempIndex == 0 {
            self.baseUseFunction()
        }
        
        if tempIndex == 1 {
            self.advanceUseFunction()
        }
        
        if tempIndex == 2 {
            self.sizeCaculateFunction()
        }
        
        if tempIndex == 3 {
            self.imageRelatedFunction()
        }
    }
    
    fileprivate func baseUseFunction() {
        YHAsyncTextDrawer.enableDebugMode()
        
        let item = YHAsyncMutableAttributedItem.itemWithText("")
        
//        let text1 = YHAsyncMutableAttributedItem.itemWithText("YHAsyncDisplayKit 是一种高效的UI渲染框架")
//        text1.setFont(UIFont.systemFont(ofSize: 12))
//        text1.setColor(UIColor.orange)

//        _ = item.appendAttributedItem(text1)
//
//        let text2 = YHAsyncMutableAttributedItem.itemWithText("🐉 大佬 大佬 YHAsyncDisplayKit 龙哥 666 vの")
//        text2.setFont(UIFont.systemFont(ofSize: 30))
//        text2.setColor(UIColor.blue)

//        _ = item.appendAttributedItem(text2)
        
//        let text3 = YHAsyncMutableAttributedItem.itemWithImageName("story_icon", inSize: CGSize.init(width: 18, height: 18))
        _ = item.appendImageWithName("story_icon", inSize: CGSize.init(width: 18, height: 18))
        _ = item.appendImageWithName("story_icon", inSize: CGSize.init(width: 30, height: 30))
//        item.appendImageWithUrl("story_icon", inSize: CGSize.init(width: 18, height: 18))
//        _ = item.appendAttributedItem(text3)
        
        let view = YHAsyncMixedView.init(frame: CGRect.zero)
        view.attributedItem = item
        
        if let size = item.resultString?.attributedSizeConstrained(self.view.frame.size.width) {
            view.setFrame(CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        self.scrollView.addSubview(view)
    }
    
    fileprivate func advanceUseFunction() {
//        YHAsyncTextDrawer.enableDebugMode()
        
        let text1 = YHAsyncMutableAttributedImage.itemWithText("雕工")
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


        let text = YHAsyncMutableAttributedImage.itemWithText("")
        _ = text.appendImageWithImage(contentImage1,inSize: contentImage1!.size)
        _ = text.appendImageWithImage(contentImage2,inSize: contentImage2!.size, imageEdge:UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 0))
        
        let size = text.resultString?.attributedSizeConstrained(self.view.frame.size.width,numberOfLines: 1)

        let view = YHAsyncMixedView.init(frame: CGRect.zero)
        view.attributedItem = text
        
        view.addTarget(self, action: #selector(didClick), controlEvents: UIControl.Event.touchUpInside)

        view.frame = CGRect.init(x: 0, y: 0, width: size!.width, height: size!.height)

        self.scrollView.addSubview(view)
    }
    
    lazy var text:UITextView = {
        let text = UITextView(frame: CGRect.zero)
        text.text = "Graver是一种高效的UI渲染框架"
        text.textColor = UIColor.black
        text.layer.borderColor = UIColor.red.cgColor
        text.layer.cornerRadius = 1
        text.layer.borderWidth = 1.0
        return text
    }()
    
    lazy var widthNumber:UITextField = {
        let width = UITextField.init()
        width.placeholder = "宽度限制"
        width.font = UIFont.systemFont(ofSize: 13)
        width.text = "60"
        width.textAlignment = .center
        width.layer.borderColor = UIColor.red.cgColor
        width.layer.borderWidth = 1.0
        width.layer.cornerRadius = 3
        return width
    }()
    
    lazy var linenumber:UITextField = {
        let line = UITextField()
        line.placeholder = "行数限制"
        line.textAlignment = .center
        line.text = "3"
        line.textAlignment = .center
        line.layer.borderColor = UIColor.red.cgColor
        line.layer.borderWidth = 1.0
        line.layer.cornerRadius = 3
        return line
    }()
    
    fileprivate func sizeCaculateFunction() {
        var spaceYStar:CGFloat = 20
        self.text.frame = CGRect.init(x: 10, y: spaceYStar, width: self.view.frame.width - 20, height: 60)
        self.text.becomeFirstResponder()
        self.scrollView.addSubview(text)
        
        spaceYStar += 80;
        
        let widthW = UILabel.init(frame: CGRect.init(x: 10, y: spaceYStar, width: 100, height: 30))
        widthW.text = "宽度限制:"
        widthW.font = UIFont.systemFont(ofSize: 13)
        widthW.textColor = UIColor.black
        self.scrollView.addSubview(widthW)
        
        self.widthNumber.frame = CGRect.init(x: 90, y: spaceYStar - 5, width: 100, height: 30)
        self.scrollView.addSubview(widthNumber)
        
        spaceYStar += 40
        
        let widthL = UILabel.init(frame: CGRect.init(x: 10, y: spaceYStar, width: 80, height: 30))
        widthL.text = "行数限制:"
        widthL.font = UIFont.systemFont(ofSize: 13)
        widthL.textColor = UIColor.black
        self.scrollView.addSubview(widthL)
        
        self.linenumber.frame = CGRect.init(x: 90, y: spaceYStar - 5, width: 100, height: 30)
        self.scrollView.addSubview(linenumber)
        
        spaceYStar += 50
        
        let button = UIButton.init(frame: CGRect.init(x: 10, y: spaceYStar, width: self.view.frame.width - 20, height: 40))
        button.setTitle("点击查看效果", for: UIControl.State.normal)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(didClick), for: UIControl.Event.touchUpInside)
        self.scrollView.addSubview(button)
    }
    
    lazy var effectView:YHAsyncMixedView = {
        let view  = YHAsyncMixedView.init(frame: CGRect.init(x: 10, y: 260, width: 0, height: 0))
        view.borderColor = UIColor.red
        view.borderWidth = 0.5
        view.cornerRadius = 1
        self.scrollView.addSubview(view)
        return view
    }()
    
    @objc func didClick() {
        text.resignFirstResponder()
        widthNumber.resignFirstResponder()
        linenumber.resignFirstResponder()
        guard let width = widthNumber.text else { return }
        guard let lineNumber = linenumber.text else { return }
        guard let string = text.text else { return }
        
        let dwidth:Double = Double(width) ?? 0
        let widthF:CGFloat = (CGFloat(dwidth) > self.view.frame.size.width - 20) ? self.view.frame.size.width - 20 : CGFloat(dwidth)
        
        let dlineNumber:Double = Double(lineNumber) ?? 0
        
        let item = YHAsyncMutableAttributedItem.init(string)
        item.setFont(UIFont.systemFont(ofSize: 13))
        item.setColor(UIColor.red)
        
        guard let size = item.resultString?.attributedSizeConstrained(widthF, numberOfLines: NSInteger(dlineNumber)) else { return }
        
        effectView.frame = CGRect(x: (self.view.frame.size.width - size.width)/2, y: 260, width: size.width, height: size.height);
        effectView.attributedItem = item
        effectView.numberOfLines = NSInteger(dlineNumber)
        
    }
    
    func imageRelatedFunction() {
        var spaceYStart:CGFloat = 0
        spaceYStart = self.basicImageUseDemoWithStartY(spaceYStart)
        spaceYStart += 5
        _ = self.addLineWithSpaceYStart(spaceYStart)
    }
    
    func basicImageUseDemoWithStartY(_ startY:CGFloat) -> CGFloat {
        let singleLineCount:CGFloat = 4
        let width:CGFloat = (self.scrollView.frame.size.width - 15 * 2 - (singleLineCount - 1) * 15) / singleLineCount
        let imgSize = CGSize.init(width: width, height: width)
        var imageArray = [UIImage]()
        
        // 纯色图片
        let image1 = UIImage.imageCreateWithColor(UIColor.green, inSize: imgSize)
        imageArray.append(image1!)
        
        // 纯色带框图片
        let image2 = UIImage.imageCreateWithColor(UIColor.green, inSize: imgSize, borderWidth: 0, inBorderColor: nil, cornerRadius: 0)
        imageArray.append(image2!)
        
        // 纯色圆角图片
        let image3 = UIImage.imageCreateWithColor(UIColor.green, inSize: imgSize, borderWidth: 0, inBorderColor: nil, cornerRadius: 10)
        imageArray.append(image3!)
        
        // 纯色圆角框
        let image4 = UIImage.imageCreateWithColor(UIColor.green, inSize: imgSize, borderWidth: 2, inBorderColor: UIColor.red, cornerRadius: 10)
        imageArray.append(image4!)
        
        // 透明带框图片
        let image5 = UIImage.imageCreateWithColor(UIColor.clear, inSize: imgSize, borderWidth: 2, inBorderColor: UIColor.red, cornerRadius: 0)
        imageArray.append(image5!)
        
        // 透明带框圆角图片
        let image6 = UIImage.imageCreateWithColor(UIColor.clear, inSize: imgSize, borderWidth: 2, inBorderColor: UIColor.red, cornerRadius: 10)
        imageArray.append(image6!)
        
        // 透明带框圆角图片
        let image7 = UIImage.imageCreateWithColor(UIColor.clear, inSize: imgSize, borderWidth: 2, inBorderColor: UIColor.red, cornerRadius: YHAsyncCornerRadiusMake(inTopLeft: 0, inTopRight: 20, inBottomLeft: 20, inBottomRight: 0))
        imageArray.append(image7!)
        
        
        var spaceXStart:CGFloat = 0;
        var spaceYStart:CGFloat = startY;
        for index in 0 ..< imageArray.count {
            if index == 0 {
                spaceXStart = 15
                spaceYStart += 10
            } else {
                if index % Int(singleLineCount) == 0 {
                    spaceXStart = 15
                    spaceYStart += imgSize.height
                    spaceYStart += 15
                } else {
                    spaceXStart += imgSize.width
                    spaceXStart += 15
                }
            }
            let imgView = UIImageView.init(frame: CGRect.init(x: spaceXStart, y: spaceYStart, width: imgSize.width, height: imgSize.height))
            imgView.image = imageArray[index]
            self.scrollView.addSubview(imgView)
        }
        
        
        spaceYStart += imgSize.height;
        spaceYStart += 15;
        
        return spaceYStart
    }
    
    func addLineWithSpaceYStart(_ spaceYStart:CGFloat) -> CGFloat {
        let singleline = UIView.init(frame: CGRect.init(x: 10, y: spaceYStart, width: self.scrollView.frame.width - 20 , height: 1 / UIScreen.main.scale))
        singleline.backgroundColor = UIColor.gray
        self.scrollView.addSubview(singleline)
        return spaceYStart + 1
    }
}
