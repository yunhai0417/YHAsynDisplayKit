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

//#pragma mark - Event Handle
extension YHAsyncTextDrawer {

//    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let contextView = self.eventDelegateContextView() else { return }
//        guard let location = touches.first?.location(in: contextView) else { return }
//        guard let drawOrigin = drawOrigin else { return }
//        let layoutLocation = self.convertPointToLayout(location, drawOrigin)
//        
//        if let activeRanges = self.eventDelegateActiveRanges() {
//            if let activeRange = self.rangeInRanges(activeRanges, forLayoutLocation: layoutLocation) {
//                self.pressingActiveRange = activeRange
//                contextView.setNeedsDisplay()
//            }
//        }
//        
//        _touchesBeginPoint = location
//    }
//    
//    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let contextView = self.eventDelegateContextView() else { return }
//        let respondingRadius:CGFloat = 50
//        guard let location = touches.first?.location(in: contextView) else { return }
//
//        guard let touchesBeginPoint = _touchesBeginPoint else { return }
//        let movedDistance:CGFloat = CGFloat(sqrt(pow((location.x - touchesBeginPoint.x), 2.0) + pow((location.y - touchesBeginPoint.y), 2.0)))
//        
//        let response = movedDistance <= respondingRadius
//        if let pressingActiveRange = self.pressingActiveRange {
//            if !response {
//                self.savedPressingActiveRange = self.pressingActiveRange
//                self.pressingActiveRange = nil
//                
//                contextView.setNeedsDisplay()
//            }
//        }
//        
//        if let savedPressingActiveRange = self.savedPressingActiveRange {
//            if response {
//                self.pressingActiveRange = self.savedPressingActiveRange
//                self.savedPressingActiveRange = nil
//                
//                contextView.setNeedsDisplay()
//            }
//        }
//    }
//    
//    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if _lastTouchEndedTimeStamp != event?.timestamp {
//            self.savedPressingActiveRange = nil
//            if let timestamp = event?.timestamp {
//                _lastTouchEndedTimeStamp = timestamp
//            }
//            if let pressingActiveRange = self.pressingActiveRange {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                    self.eventDelegateDidPressActiveRange(pressingActiveRange)
//                }
//            }
//            
//            _touchesBeginPoint = CGPoint.zero
//            
//            // 若用户点击速度过快，hitRange高亮状态还未绘制又取消高亮会导致没有高亮效果
//            // 故延迟执行
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                self.pressingActiveRange = nil
//                self.eventDelegateContextView()?.setNeedsDisplay()
//            }
//        }
//    }
//    
//    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.savedPressingActiveRange = nil
//        if let _ = self.pressingActiveRange {
//            self.pressingActiveRange = nil
//            self.eventDelegateContextView()?.setNeedsDisplay()
//        }
//    }
}


//#pragma mark - HitTest
extension YHAsyncTextDrawer {
    func rangeInRanges(_ ranges:[YHAsyncTextActiveRange], forLayoutLocation location:CGPoint) -> YHAsyncTextActiveRange? {
        for activeRange in ranges {
            var hit = false
            guard let range = activeRange.range else { continue }
            self.getTextLayout().layoutFrame?.enumerateEnclosingRectsForCharacterRange(range, { (rect, characterRange, stop) in
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
