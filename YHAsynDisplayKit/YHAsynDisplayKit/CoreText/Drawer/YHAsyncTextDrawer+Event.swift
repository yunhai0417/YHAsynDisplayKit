//
//  YHAsyncTextLayout+Event.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/4.
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

struct YHAsyncTextDrawerDelegateHas {
    var placeAttachment:Bool = true
}

struct YHAsyncTextDrawerEventDelegateHas {
    var contextView:Bool = true
    var activeRanges:Bool = true
    var didPressActiveRange:Bool = true
    var didHighlightedActiveRange:Bool = true
    var shouldInteractWithActiveRange:Bool = true
}


//#pragma mark - HitTest
extension YHAsyncTextDrawer {
    func rangeInRanges(_ ranges:[YHAsyncTextActiveRange], forLayoutLocation location:CGPoint) -> YHAsyncTextActiveRange? {
        for activeRange in ranges {
            var hit = false
            guard let range = activeRange.range else { continue }
            self.textLayout.layoutFrame?.enumerateEnclosingRectsForCharacterRange(range, { (rect, characterRange, stop) in
                if let rect = rect {
                    if rect.contains(location) {
                        hit = true
                        stop = true
                    }
                }
            })
            
            if hit && _eventDelegateHas.shouldInteractWithActiveRange {
                if let hit1 = eventDelegate?.textDrawer(self, shouldInteract: activeRange) {
                    hit = hit1
                }
            }
            
            if hit {
                return activeRange
            }
            
        }
        
        
        
        return nil
    }
}


//#pragma mark - Event Delegate
extension YHAsyncTextDrawer {
    func eventDelegateContextView() -> UIView? {
        if _eventDelegateHas.contextView {
            return eventDelegate?.contextViewForTextDrawer(self)
        }
        return nil
    }
    
    func eventDelegateActiveRanges() -> [YHAsyncTextActiveRange]? {
        if _eventDelegateHas.activeRanges {
            return eventDelegate?.activeRangesForTextDrawer(self)
        }
        
        return nil
    }
    
    func eventDelegateDidPressActiveRange(_ activeRange:YHAsyncTextActiveRange) {
        if _eventDelegateHas.didPressActiveRange {
            eventDelegate?.textDrawer(self, didPress: activeRange)
        }
    }
}
