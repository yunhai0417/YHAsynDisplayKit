//
//  YHAsyncMutableAttributedImage.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/20.
//  Copyright © 2020 YH. All rights reserved.
//

import UIKit

public class YHAsyncMutableAttributedImage: YHAsyncMutableAttributedItem {

    override public func appendAttachment(_ att: YHAsyncTextAttachment) -> YHAsyncMutableAttributedItem {
        att.retriveFontMetricsAutomatically = false
        att.edgeInsets = UIEdgeInsets.zero
        att.position = 0
        att.length = 1
        
        guard let height = att.size?.height else { return self }
        
        let metricFont = YHAsyncFontMetricsCreateMake(UIFont.systemFont(ofSize: 11))
        let metric = YHAsyncFontMetricsCreateMakeWithLineHeight(metricFont, targetLineHeight: floor(height))
        att.baselineFontMetrics = metric
        return super.appendAttachment(att)
    }

}
