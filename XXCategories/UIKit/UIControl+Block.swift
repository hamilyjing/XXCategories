//
//  UIControl+Block.swift
//  XXCategories
//
//  Created by 任龙宇 on 15/11/14.
//  Copyright © 2015年 here. All rights reserved.
//

import Foundation
import UIKit

extension UIControl {
    
    public typealias ActionBlock = (sender: AnyObject) -> Void
    
    private class _BlockTarget {
        
        var events: UIControlEvents?
        var block: ActionBlock?
        
        init(events: UIControlEvents, block: ActionBlock) {
            self.events = events
            self.block = block
        }
        
        @objc func invoke(sender: AnyObject) {
            if let block = self.block {
                block(sender: sender)
            }
        }
    }
    
    private struct AssociatedKeys {
        static var BlockTargetsKey = "BlockTargetsKey"
    }
    
    private var blockTargets: NSMutableArray {
        get {
            if let targets = objc_getAssociatedObject(self, &AssociatedKeys.BlockTargetsKey) as? NSMutableArray {
                return targets
            } else {
                let targets = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.BlockTargetsKey, targets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return targets
            }
        }
    }
    
    //MARK: - public func
    
    public func removeTargets() {
        for target in self.allTargets() {
            self.removeTarget(target, action: nil, forControlEvents: UIControlEvents.AllEvents)
        }
        blockTargets.removeAllObjects()
    }
    
    public func addAction(controlEvents: UIControlEvents, block: ActionBlock) {
        let target = _BlockTarget(events: controlEvents, block: block)
        self.addTarget(target, action: Selector("invoke:"), forControlEvents: controlEvents)
        blockTargets.addObject(target)
    }
    
    public func removeAction(controlEvents: UIControlEvents) {
        let removes = NSMutableArray()
        for t in blockTargets {
            if let target = t as? _BlockTarget {
                if target.events == controlEvents {
                    self.removeTarget(target, action: Selector("invoke:"), forControlEvents: controlEvents)
                    removes.addObject(target)
                }
            }
        }
        blockTargets.removeObjectsInArray(removes as [AnyObject])
    }
}
