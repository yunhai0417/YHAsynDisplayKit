//
//  YHAsyncImage.swift
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
import SDWebImage


public class YHAsyncImage: NSObject {

    // 网络图片的下载URL string
    public var downloadUrl:String?
    
    // 本地占位图片名字
    public var placeholderName:String?
    
    // 肯能是最终展示的本地图片、可能是展示的placeholder图片、也可能是下载的网络图片
    public var image:UIImage?

    // 下载图片的size
    public var size:CGSize?
    
    // 对图片的圆角说明
    public var radius:YHAsyncCornerRadius = YHAsyncCornerRadiusZero
    
    // 为图片添加的border宽度
    public var borderWidth:CGFloat = 0
    
    // 图片的模糊处理
    public var blurPercent:CGFloat = 0
    
    // 图片展示的内容模式
    public var contentMode:UIView.ContentMode = UIView.ContentMode.center
    
    // 如果涉及点击效果，代表高亮颜色
    public var highlightColor:UIColor?
    
    // 如果涉及点击效果，代表高亮展示的图片
    public var highlightImage:UIImage?
    
    /**
    * 根据指定图片名称创建YHAsyncImage
    *
    * @param imgname 图片名称
    *
    */
    
    public class func imageWithNamed(_ imgName:String) -> YHAsyncImage? {
        if imgName.isEmpty {
            return nil
        }
        
        let ctImage = YHAsyncImage.init()
        ctImage.placeholderName = imgName
        
        return ctImage
    }
    
    /**
    * 根据指定图片创建YHAsyncImage
    *
    * @param image 图片
    *
    */
    public class func imageWithImage(_ image:UIImage?) -> YHAsyncImage? {
        if let image = image {
            let ctImage = YHAsyncImage.init()
            ctImage.image = image
            return ctImage
        }
        return nil
    }
    
    /**
    * 根据指定图片url创建YHAsyncImage
    *
    * @param imgUrl 图片url
    *
    */
    
    public class func imageWithUrl(_ imgUrl:String) -> YHAsyncImage? {
        if imgUrl.isEmpty {
            return nil
        }
        let ctImage = YHAsyncImage.init()
        ctImage.downloadUrl = imgUrl
        return ctImage
    }
    
    /**
    * 根据图片的url下载图片
    *
    * @param urlStr 图片url
    * @param options 详见SDWebImage
    * @param progressBlock 详见SDWebImage
    * @param completion 详见SDWebImage
    *
    */
    public func loadImageWithUrl(_ urlStr:String, inoptions options:SDWebImageOptions, inprogress progress:SDWebImageDownloaderProgressBlock?, inCompleted completed:SDExternalCompletionBlock?) {
        guard let url = URL.init(string: urlStr) else {
            self.downloadUrl = nil
            let error = NSError.init(domain: SDWebImageErrorDomain, code: -1 , userInfo: [NSLocalizedDescriptionKey : "Trying to load a nil url"])
            if let completed = completed {
                completed(nil, error, SDImageCacheType.none, nil)
            }
            return
        }
        
        SDWebImageManager.shared.loadImage(with: url, options: options, progress: progress) { (rimage, rdata, rerror, rcacheType, rfinished, rimageUrl) in
            guard let size = self.size else { return }
            
            let scale = UIScreen.main.scale
            let imageSize = CGSize.init(width: size.width * scale, height: size.height * scale)
            
            let contentMode = self.contentMode
            let percent:CGFloat = self.blurPercent / 100.0
            
            
            let radius1:YHAsyncCornerRadius = YHAsyncCornerRadiusMake(inTopLeft: self.radius.topLeft * scale,
                                                                     inTopRight: self.radius.topRight * scale,
                                                                     inBottomLeft: self.radius.bottomLeft * scale,
                                                                     inBottomRight: self.radius.bottomRight * scale)
            
            DispatchQueue.global().async {
                // 裁剪处理
                var newImage = rimage?.yh_cropImageWithCroppedSize(imageSize, resizeMode: contentMode, interpolationQuality:CGInterpolationQuality.high)
                
                // 模糊处理
                if percent >= 0.01 {
                    newImage = newImage?.yh_blurImageWithBlurPercent(percent)
                }
                
                // 圆角处理
                if !YHAsyncCornerRadiusEqual(inR: radius1, inL: YHAsyncCornerRadiusZero) {
                    newImage = newImage?.yh_roundedImageWithCornerRadius(radius1)
                }
                
                DispatchQueue.main.async {
                    self.downloadUrl = nil
                    self.image = rimage
                    if let completeBlock = completed {
                        if rfinished {
                            completeBlock(rimage,rerror,rcacheType,rimageUrl)
                        }
                    }
                    
                }
            }
        }
    }
}
