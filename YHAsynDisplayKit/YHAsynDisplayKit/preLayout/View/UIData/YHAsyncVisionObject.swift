//
//  YHAsyncVisionObject.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/22.
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
import CoreGraphics

/*
视觉元素的抽象, 在Graver框架中，对所有视觉元素进行抽象，即每个视觉元素都由其位置、大小、内容唯一决定
*/
open class YHAsyncVisionObject: NSObject {
    //视觉元素的位置，大小
    public var visionFrame:CGRect = CGRect.zero
    
    // 视觉元素的展示内容，多数情况下，value即是YHAsyncMutableAttributedItem
    public var visionValue:YHAsyncMutableAttributedItem?
}
