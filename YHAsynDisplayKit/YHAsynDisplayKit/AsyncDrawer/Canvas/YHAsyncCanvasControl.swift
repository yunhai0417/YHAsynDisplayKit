//
//  YHAsyncCanvasControl.swift
//  YHAsynDisplayKit
//
//  Created by 吴云海 on 2020/4/1.
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

import UIKit

public class YHAsyncCanvasControlTargetAction: NSObject {
    var target:AnyObject?  //不能为空
    var action:Selector?
    var controlEvents:UIControl.Event = UIControl.Event.init(rawValue: 0)
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let targetAction = object as? YHAsyncCanvasControlTargetAction else { return false }

        return targetAction.action == self.action &&
               (targetAction.target?.isEqual(self.target) ?? false) &&
               targetAction.controlEvents == self.controlEvents
    }
}

//@objcMembers
open class YHAsyncCanvasControl: YHAsyncCanvasView {
    // how to position content vertically inside control. default is center
    public var contentHorizontalAlignment:UIControl.ContentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
    // how to position content horizontally inside control. default is center
    public var contentVerticalAlignment:UIControl.ContentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    // could be more than one state (e.g. disabled|selected). synthesized from other flags.
    public var state:[UIControl.State] {
        get {
            var states = [UIControl.State]()
            states.append(UIControl.State.normal)
            if self.highlighted {
                states.append(UIControl.State.highlighted)
            }
            
            if !self.enable {
                states.append(UIControl.State.disabled)
            }
            
            if self.selected {
                states.append(UIControl.State.selected)
            }
            
            return states
        }
    }
    // default is YES. if NO, ignores touch events and subclasses may draw differently
    fileprivate var _enable:Bool = true
    public var enable:Bool {
        set {
            if _enable != newValue {
                self.stateWillChange()
                _enable = newValue
                self.stateDidChage()
                self.isUserInteractionEnabled = newValue
            }
        }
        get {
            return _enable
        }
    }
    // default is NO may be used by some subclasses or by application
    fileprivate var _selected:Bool = false
    public var selected:Bool {
        set {
            if _selected != newValue {
                self.stateWillChange()
                _selected = newValue
                self.stateDidChage()
            }
        }
        get {
            return _selected
        }
    }
    // default is NO. this gets set/cleared automatically when touch enters/exits during tracking and cleared on up
    fileprivate var _highlighted:Bool = false
    public var highlighted:Bool {
        set {
            if _highlighted != newValue {
                self.stateWillChange()
                _highlighted = newValue
                self.stateDidChage()
            }
        }
        get {
            return _highlighted
        }
    }
    // is tracking
    fileprivate var _tracking:Bool = false
    public var isTracking:Bool {
        set {
            _tracking = newValue
        }
        get {
            return _tracking
        }
    }
    // valid during tracking only
    fileprivate var _touchInside:Bool = false
    public var isTouchInside:Bool {
        set {
            _touchInside = newValue
        }
        get {
            return _touchInside
        }
    }
    // auto redraws when state changed
    fileprivate var _redrawsAutomaticallyWhenStateChange:Bool = false
    public var redrawsAutomaticallyWhenStateChange:Bool {
        set {
            _redrawsAutomaticallyWhenStateChange = newValue
        }
        get {
            return true
        }
    }
        
    // add target/action for particular event. you can call this multiple times and you can specify multiple target/actions for a particular event.
    // passing in nil as the target goes up the responder chain. The action may optionally include the sender and the event in that order
    // the action cannot be NULL. Note that the target is not retained.
    
    fileprivate var _targetActions:[YHAsyncCanvasControlTargetAction]?
    
    fileprivate var targetActions:[YHAsyncCanvasControlTargetAction]? {
        set {
            _targetActions = newValue
        }
        get {
            if let targetActions = _targetActions {
                return targetActions
            }
            _targetActions = [YHAsyncCanvasControlTargetAction]()
            return _targetActions
        }
    }
    
    
    fileprivate var touchStartPoint:CGPoint?
    
    deinit {
        self.targetActions?.removeAll()
        self.targetActions = nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.enable = true
        self.isExclusiveTouch = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func stateWillChange() {
    }
    
    fileprivate func stateDidChage() {
        if self.redrawsAutomaticallyWhenStateChange {
            self.setNeedsLayout()
            self.setNeedsLayout()
        }
    }
    
    public func addTarget(_ target: AnyObject, action:Selector, controlEvents:UIControl.Event) {
        let actionMode = YHAsyncCanvasControlTargetAction.init()
        actionMode.target = target
        actionMode.action = action
        actionMode.controlEvents = controlEvents
        
        self.targetActions?.append(actionMode)
    }
    
    // remove the target/action for a set of events. pass in NULL for the action to remove all actions for that target
    public func removeTarget(_ target: AnyObject, action: Selector, controlEvents:UIControl.Event) {
        let actionMode = YHAsyncCanvasControlTargetAction.init()
        actionMode.target = target
        actionMode.action = action
        actionMode.controlEvents = controlEvents
        
        self.targetActions?.removeAll(where: { targetActionMode -> Bool in
            return targetActionMode.isEqual(actionMode)
        })
    }
    
    // single event. returns NSArray of NSString selector names. returns nil if none
    public func actionsForTarget(_ target: AnyObject, controlEvents:UIControl.Event?) -> [Selector]? {
        guard let targetActions = self.targetActions else {
            return nil
        }
        guard let controlEvents = controlEvents else {
            return nil
        }
        
        var actions = [Selector]()
        for actionMode in targetActions {
            if (actionMode.target?.isEqual(target) ?? false ) && actionMode.controlEvents == controlEvents {
                if let actionSel = actionMode.action {
                    actions.append(actionSel)
                }
            }
        }
        
        if actions.count > 0 {
            return actions
        }
        
        return nil
    }
    // set may include NSNull to indicate at least one nil target
    public func allTargets() -> Set<YHAsyncCanvasControlTargetAction>? {
        guard let targetActions = self.targetActions else { return nil }
        let allTargets = Set<YHAsyncCanvasControlTargetAction>(targetActions)
        return allTargets
    }
    
    // list of all events that have at least one action
    fileprivate func allControlEvents() -> UIControl.Event{
        var allEvents = UIControl.Event.init(rawValue: 0)
//        var allEvents = [UIControl.Event]()
        guard let targetActions = self.targetActions else {
            return allEvents
        }
        
        for targetActionMode in targetActions {
            let event = targetActionMode.controlEvents
            allEvents = UIControl.Event.init(rawValue: event.rawValue | allEvents.rawValue)
        }
        
        return allEvents
    }
    
    // send all actions associated with events
    fileprivate func sendActionsForControlEvents(_ controlEvents:UIControl.Event) {
        self.sendActionsForControlEvents(controlEvents, withEvent: nil)
    }
    
    // send the action. the first method is called for the event and is a point at which you can observe or override behavior. it is called repeately by the second.
    fileprivate func sendAction(_ action:Selector, to:Any, forEvent:UIEvent?) {
        UIApplication.shared.sendAction(action, to: to, from: self, for: forEvent)
    }

    open func beginTrackingWithTouch(_ touch:UITouch, withEvent:UIEvent?) -> Bool {
        return true
    }
    
    open func continueTrackingWithTouch(_ touch:UITouch, withEvent:UIEvent?) -> Bool {
        return true
    }

    open func endTrackingWithTouch(_ touch:UITouch, withEvent:UIEvent?) {
        
    }

    open func cancelTrackingWithEvent(_ event:UIEvent?) {
        
    }

    fileprivate func sendActionsForControlEvents(_ inControlEvents:UIControl.Event, withEvent:UIEvent?) {
        guard let targetActions = self.targetActions else {
            return
        }
        
        for targetMode in targetActions {
            let controlEvents = targetMode.controlEvents 
            
            if inControlEvents != controlEvents  {
                continue
            }
            guard let target = targetMode.target else { continue }
            guard let action = targetMode.action else { continue }
            
            self.sendAction(action, to: target, forEvent: nil)
        }
        
    }
    
    //override
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.isTouchInside = true
        self.isTracking = self.beginTrackingWithTouch(touch, withEvent: event)
        self.highlighted = true
        
        if self.isTracking {
            var currentEvents = UIControl.Event.touchDown
            
            if touch.tapCount > 1 {
                currentEvents = UIControl.Event.init(rawValue: currentEvents.rawValue | UIControl.Event.touchDownRepeat.rawValue)
            }
            self.sendActionsForControlEvents(currentEvents, withEvent: event)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = false
        if self.isTracking {
            self.cancelTrackingWithEvent(event)
            self.sendActionsForControlEvents(UIControl.Event.touchCancel, withEvent: event)
        }
        
        self.isTouchInside = false
        self.isTracking = false
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.isTouchInside = self.point(inside: touch.location(in: self), with: event)
        
        self.highlighted = false
        
        if self.isTracking {
            self.endTrackingWithTouch(touch, withEvent: event)
            
            let events = isTouchInside ? UIControl.Event.touchUpInside : UIControl.Event.touchUpOutside
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.sendActionsForControlEvents(events, withEvent: event)
            }
        }
        
        self.isTracking = false
        self.isTouchInside = false

    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let wasTouchInside:Bool = self.isTouchInside

        self.isTouchInside = self.point(inside: touch.location(in: self), with: event)
        
        self.highlighted = self.isTouchInside
        
        if self.isTracking {
            self.isTracking = self.continueTrackingWithTouch(touch, withEvent: event)
            
            if isTracking {
                var currentEvents = UIControl.Event.init(rawValue: 0)
                
                if isTouchInside {
                    currentEvents = UIControl.Event.init(rawValue: currentEvents.rawValue | UIControl.Event.touchDragInside.rawValue)
                } else {
                    currentEvents = UIControl.Event.init(rawValue: currentEvents.rawValue | UIControl.Event.touchDragOutside.rawValue)
                }
                
                if !wasTouchInside && isTouchInside {
                    currentEvents = UIControl.Event.init(rawValue: currentEvents.rawValue | UIControl.Event.touchDragEnter.rawValue)
                } else if wasTouchInside && !isTouchInside {
                    currentEvents = UIControl.Event.init(rawValue: currentEvents.rawValue | UIControl.Event.touchDragExit.rawValue)
                }
                
                self.sendActionsForControlEvents(currentEvents, withEvent: event) // TODO
            }
        }
    }
}
